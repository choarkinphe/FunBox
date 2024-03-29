//
//  FunDownloadManager.swift
//  FunFreedom
//
//  Created by 肖华 on 2020/3/26.
//

import Foundation
import Alamofire
import FunBox



fileprivate let FunDownloadLocalResponderPathName = "com.funfreedom.FunDownloadLocalResponderPathName"
// 默认的缓存路径
fileprivate let localResponderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/\(FunDownloadLocalResponderPathName)"
public typealias FunDownloadManager = FunBox.DownloadManager
public extension FunBox {
    class DownloadManager: NSObject {
        // 任务状态
        public enum State: String, Codable {
            case unknow = "unknow"          // 未知
            case wait = "wait"              // 等待
            case download = "download"      // 下载中
            case finish = "finish"          // 已完成
            case dormancy = "dormancy"      // 休眠
            case removed = "removed"        // 已移除
            
            public var key: String {
                switch self {
                case .dormancy: // dormancy实际上也是等待中的任务，只不过他不会自动启动
                    return State.wait.rawValue
                default:
                    return self.rawValue
                }
            }
            
        }
        
        struct Static {
            static let instance_downloadManager = DownloadManager()
        }
        
        // 主队列
        public let rootQueue = DispatchQueue(label: "com.funfreedom.download.rootQueue")
        
        public static var `default`: DownloadManager {
            return Static.instance_downloadManager
            
        }
        public var isDownloadFree: Bool {
            if let downloadTasks = downloadTasks {
                return downloadTasks.count < maxDownloadCount
            }
            return false
        }
        
        private lazy var fileManager  = FileManager.default
        
        // 生成默认的缓存路径
//        private var localResponderPath: String?
        // 创建缓存管理器
        private var cacheManager: FunCache
        
        // 最大同时下载数（默认一次下载一条）
        public var maxDownloadCount: Int = 1
        // 存储所有任务的identifier
        private var taskMap: [String]
        {
            didSet {
               NSKeyedArchiver.archiveRootObject(taskMap, toFile: localResponderPath+"/maps")
            }
        }
        
        private lazy var timer: Timer = {
            // 开启一个周期为5分钟的计时器（没5分钟主动监测一次任务状态）
            let timer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(checkTask(timer:)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: .default)
            
            return timer
        }()
        
        fileprivate lazy var session: URLSession = {
            
            let configuration = URLSessionConfiguration.background(withIdentifier: "com.funfreedom.downloadManager.background")
            
            configuration.headers = .default
            configuration.timeoutIntervalForRequest = 10
            
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
            
            return session
        }()
        
        // 下载中的任务列表
        public var downloadTasks: [String: FunDownloadManager.Responder]? {
            return allTasks[State.download.key]
        }
        // 等待列队（错误，异常终止的都会加入到等待队列）
        public var waitTasks: [String: FunDownloadManager.Responder]? {
            return allTasks[State.wait.key]
        }
        // 下载完成的列表
        public var finishedTasks: [String: FunDownloadManager.Responder]? {
            return allTasks[State.finish.key]
        }
        // 所有任务
        fileprivate var allTasks: [String: [String: FunDownloadManager.Responder]] {
            didSet {
                // 总任务列表发生变更时，检查任务状态
                checkTask(timer: nil)
            }
        }
        
        // 构造方法
        public override init() {
            // 创建默认的缓存工具
            self.cacheManager = FunCache(path: localResponderPath)
            // 缓存有效期为1000天(伪装长期有效)
            self.cacheManager.cacheTimeOut = 86400000
            
            // 首先初始化taskMap，获取下载记录
            if let maps = NSKeyedUnarchiver.unarchiveObject(withFile: localResponderPath+"/maps") as? [String] {
                
                self.taskMap = maps
            } else {
                self.taskMap = [String]()
            }
            
            // 初始化任务列表
            self.allTasks = [String: [String: FunDownloadManager.Responder]]()
            self.allTasks[State.wait.key] = [String: FunDownloadManager.Responder]()
            self.allTasks[State.download.key] = [String: FunDownloadManager.Responder]()
            self.allTasks[State.finish.key] = [String: FunDownloadManager.Responder]()
            
            super.init()
            // 获取到所有下载记录的标示后，初始化所有任务列表
            let decoder = JSONDecoder()
            self.taskMap.forEach { (identifier) in
                if let data = self.cacheManager.loadCache(key: identifier),
                    let responder = try? decoder.decode(Responder.self, from: data) {
                    // 读取磁盘存储的任务信息
                    self.allTasks[responder.state.key]?[identifier] = responder
                }
            }
            
            
            // 启动时先获取所有任务
            self.session.getAllTasks { (tasks) in
                tasks.forEach { (task) in
                    // 暂存异常任务，后续处理
                    if let downloadTask = task as? URLSessionDownloadTask {
                        // 队列中不包含此任务
                        if !self.containsTask(downloadTask) {
                            // 取消此任务
                            downloadTask.cancel { (resumeData) in
                                // 已在 didCompleteWithError 中统一做了处理
                            }
                        }
                    }
                }
            }
            
            // 初始化完成后先启动计时器（主动执行第一次的任务检测）
            timer.fire()
            
        }
        
        // 根据identifier查找任务
        public func getTask(identifier: String?) -> Responder? {
            guard let identifier = identifier else { return nil }
            
            if let responder = waitTasks?[identifier] {
                return responder
            }
            
            if let responder = downloadTasks?[identifier] {
                return responder
            }
            
            if let responder = finishedTasks?[identifier] {
                return responder
            }
            
            return nil
        }
        
        // 检查本地有没有这个任务
        private func containsTask(_ downloadTask: URLSessionDownloadTask?) -> Bool {
            
            if let task = getTask(identifier: downloadTask?.currentRequest?.identifier)?.downloadTask, task == downloadTask {
                return true
            }
            
            return false
            
        }
        
        // 构建任务
        public func buildResponder(request: URLRequest) -> DownloadManager.Responder? {
            guard let identifier = request.identifier else { return nil }
            // 判断已完成池里有没有这条任务
            if let downloadResponder = finishedTasks?[identifier] {
                
                // 已完成的任务用操作，直接抛出
                return downloadResponder
            }
            
            // 判断任务池里有没有这条任务
            if let downloadResponder = downloadTasks?[identifier] {
                
                // 下载中的任务不可再次操作，直接抛出
                return downloadResponder
            }
            
            // 判断等待池里有没有此任务
            if let downloadResponder = waitTasks?[identifier] {
                
                if let resumeData = downloadResponder.resumeData {
                    // 有恢复文件时，获取恢复文件里的数据创建任务
                    downloadResponder.downloadTask = session.downloadTask(withResumeData: resumeData)
                    
                } else {
                    // 创建新的任务
                    downloadResponder.downloadTask = session.downloadTask(with: request)
                }
                
                // 有新的任务添加进来，所以重启计时器
                timer.fireDate = Date()
                
                return downloadResponder
            }
            
            
            // 创建新任务
            let downloadTask = session.downloadTask(with: request)
            
            // 生成对应的响应器
            let responder = Responder(downloadTask: downloadTask)
            
            responder.request = request
            
            updateTask(resnponder: responder, state: .wait)
            // 有新的任务添加进来，所以重启计时器
            timer.fireDate = Date()
            
            return responder
        }
        
        // 更新任务状态（会写入磁盘）
        fileprivate func updateTask(resnponder: Responder, state: State? = nil) {
            guard let identifier = resnponder.request?.identifier else { return }
            
            rootQueue.async {
                
                if !self.taskMap.contains(identifier) {
                    self.taskMap.append(identifier)
                }

                let new_state = state ?? resnponder.state
                
                let new_responder = self.allTasks[resnponder.state.key]?.removeValue(forKey: identifier) ?? resnponder
                
                new_responder.state = new_state
                
                
                do {
                    
                    if state == .removed {
                        // 移除map
                        if let index = self.taskMap.firstIndex(of: identifier) {
                            self.taskMap.remove(at: index)
                        }
                        // 删除任务表中的数据
                        self.allTasks[resnponder.state.key]?.removeValue(forKey: identifier)
                        // 移除本地任务
                        self.cacheManager.removeCache(key: identifier)
                        
                    } else {
                        // 获取真实的Data
                        let encoder = JSONEncoder()
                        
                        let cacheData = try encoder.encode(new_responder)
                        // 先更新到新的任务表
                        self.allTasks[new_state.key]?[identifier] = new_responder
                        // 存储
                        self.cacheManager.cache(key: identifier, data: cacheData)
                    }
                    
                    // 给出任务状态变更的回调
                    if let state = state, let stateChanged = new_responder.stateChanged {
                        DispatchQueue.main.async {
                            stateChanged(state)
                        }
                    }
                    
                } catch let error {
                    debugPrint("FunDownloadManager: \(error.localizedDescription)")
                }
            }
        }
        
        /// 轮循检查任务状态
        /// - Parameter timer: 计时器（这个方法可能会由计时器唤起，用于处理异常任务）
        @objc private func checkTask(timer: Timer?) {
            
            if (waitTasks?.count ?? 0) + (downloadTasks?.count ?? 0) == 0 {
                // 任务归零时暂停计时器
                timer?.fireDate = Date.distantFuture
            }
            
            rootQueue.async {
                // 检查等待队列
                self.waitTasks?.forEach { (task) in
                    // 休眠任务不可开启
                    if self.isDownloadFree, task.value.state != .dormancy, task.value.downloadTask != nil {
                        // 更新任务状态到开启
                        self.updateTask(resnponder: task.value, state: .download)
                    }
                }
                
                // 检查下载队列
                self.downloadTasks?.forEach { (task) in
                    
                    if let downloadTask = task.value.downloadTask {
                        
                        // 真实任务存在，开启任务
                        downloadTask.resume()
                        
                    } else {
                        // 丢失的任务重置成休眠
                        // 任务丢失，移动到等待列表中等待重建任务
                        self.updateTask(resnponder: task.value, state: .dormancy)
                    }
                }
            }
            
            
        }
        
    }
}

public extension FunDownloadManager {
    
    class Responder: Codable {
        // 任务状态
        public var state: State = .unknow
        // 任务状态变更的回调
        fileprivate var stateChanged: ((State)->Void)?
        public func stateChanged(_ a_stateChanged: ((State)->Void)?) {
            stateChanged = a_stateChanged
        }
        // 文件地址
        public var fileURL: URL?
        // 请求信息
        public var request: URLRequest?
        // 实际的下载任务
        fileprivate var downloadTask: URLSessionDownloadTask? {
            didSet {
                request = downloadTask?.currentRequest
                fileName = downloadTask?.response?.suggestedFilename
            }
        }
        // 文件名
        public var fileName: String?
        // 下载进度
        public lazy var progress = Progress() // 实际存储的对象
        fileprivate var progressHandler: ((Progress)->Void)? // 获取任务进度的回调
        public func progressHandler(_ a_progressHandler: ((Progress)->Void)?) -> Self {
            progressHandler = a_progressHandler
            return self
        }
        public func progress(_ a_progress: ((Progress)->Void)?) {
            progressHandler = a_progress
        }
        // 恢复文件
        public var resumeData: Data?
        // 储存路径
        public var destinationURL: URL?
        // 是否休眠（可以永远不会自动执行下载，但是始终存在于等待队列）
//        public var isDormancy: Bool = true
        // 任务完成/失败后的回调
        fileprivate var complete: ((URL?,Error?)->Void)?
        public func complete(_ a_complete: ((URL?,Error?)->Void)?) {
            complete = a_complete
        }
        
        // 任务构建方法
        public init(downloadTask: URLSessionDownloadTask?) {
            self.downloadTask = downloadTask
            request = downloadTask?.currentRequest
        }
        
        // 开始任务
        public func response(_ a_complete: ((URL?,Error?)->Void)?) {
            if state == .finish { // 任务已完成的，直接终止
                if let complete = a_complete {
                    complete(fileURL,nil)
                }
                
                return
            }
            // 关闭休眠状态，让任务可以添加到下载队列
//            isDormancy = false
//            state = .wait
            FunDownloadManager.default.updateTask(resnponder: self, state: .wait)
            complete = a_complete
        }
        
        /// 暂停任务
        public func suspend() {
            // 暂停任务（此时不一定能拿到任务，没有拿到的话会在checkTask循环里自动执行）
            downloadTask?.cancel(byProducingResumeData: { (resumeData) in
                self.resumeData = resumeData
            })
            // 将任务状态调整为休眠
//            isDormancy = false
//            state = .dormancy
            FunDownloadManager.default.updateTask(resnponder: self, state: .dormancy)
        }
        
        
        /// 移除任务
        /// - Parameter sameAsFile: 同时删除源文件
        public func remove(sameAsFile: Bool? = false) {
            // 首先取消掉这条任务
            downloadTask?.cancel()
            // 删除resumeData
            resumeData = nil
            // 删除本地文件
            if let fileURL = fileURL {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                }
                catch {
                    debugPrint(error)
                }
            }
            // 更新任务状态为删除
            FunDownloadManager.default.updateTask(resnponder: self, state: .removed)
        }
        
        private enum CodingKeys: String,CodingKey {
            case request
            case state
            case params
            case url
            case headers
            case method
            case resumeData
            case destinationURL
            case fileURL
            case fileName
//            case isDormancy
            case totalUnitCount
            case completedUnitCount
        }
        
        required public init(from decoder: Decoder) throws {
            do {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                resumeData = try? container.decode(Data.self, forKey: .resumeData)
                destinationURL = try? container.decode(URL.self, forKey: .destinationURL)
                fileURL = try? container.decode(URL.self, forKey: .fileURL)
//                isDormancy = (try? container.decode(Bool.self, forKey: .isDormancy)) ?? true
                
                progress.totalUnitCount = (try? container.decode(Int64.self, forKey: .totalUnitCount)) ?? 0
                progress.completedUnitCount = (try? container.decode(Int64.self, forKey: .completedUnitCount)) ?? 0
                
                state = (try? container.decode(State.self, forKey: .state)) ?? FunDownloadManager.State.unknow
                fileName = try? container.decode(String.self, forKey: .fileName)
                if let url = try? container.decode(URL.self, forKey: .url) {
                    request = URLRequest(url: url)
                    request?.httpMethod = try? container.decode(String.self, forKey: .method)
                    request?.httpBody = try? container.decode(Data.self, forKey: .params)
                    request?.allHTTPHeaderFields = try? container.decode([String: String].self, forKey: .headers)
                }
            }
            catch {
                print(error)
            }
            
        }
        
        public func encode(to encoder: Encoder) throws {
            do {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(request?.httpBody, forKey: .params)
                try container.encode(request?.url, forKey: .url)
                try container.encode(request?.httpMethod, forKey: .method)
                try container.encode(request?.allHTTPHeaderFields, forKey: .params)
                try container.encode(destinationURL, forKey: .destinationURL)
                try container.encode(fileURL, forKey: .fileURL)
                try container.encode(resumeData, forKey: .resumeData)
                try container.encode(progress.completedUnitCount, forKey: .completedUnitCount)
                try container.encode(progress.totalUnitCount, forKey: .totalUnitCount)
                try container.encode(state, forKey: .state)
                try container.encode(fileName, forKey: .fileName)
            }
            catch {
                
            }
        }
    }
}

extension FunDownloadManager: URLSessionTaskDelegate, URLSessionDownloadDelegate {
    // 任务完成、失败、手动停止都会走这里
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // 下载结束，先查看有没有这条任务
        if let identifier = task.currentRequest?.identifier, let responder = getTask(identifier: identifier) {
            if let error = error {
                // 下载出错，先看有没有恢复文件
                if let ns_error = error as NSError?, let resumeData = ns_error.userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                    // 找到对应的恢复文件，并且存储
                    responder.resumeData = resumeData
                    // 自动恢复的任务开启休眠，防止后台误启动
//                    responder.state = .dormancy
                    // 加入等待列队
                    updateTask(resnponder: responder, state: .dormancy)
                } else {
                    // 没有恢复文件的，直接报错出去
                    if let complete = responder.complete {
                        complete(nil,error)
                    }
                }
                
            } else {
                // 没有错误，给出成功的回调
                if let complete = responder.complete {
                    complete(responder.fileURL,error)
                }
            }
        } else {
            // 找不到对应任务信息的
        }
        
        // 直接取消掉任务，有恢复文件的存在，所以可以自己重建
        task.cancel()
    }
    
    // 任务被重启
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        // 获取当前任务标示
        if let identifier = downloadTask.currentRequest?.identifier, let responder = getTask(identifier: identifier) {
            
            // 任务已经开始了，就移除恢复信息
            responder.resumeData = nil
            
            // 更新任务状态
            updateTask(resnponder: responder, state: .download)
            //            cacheManager.removeCache(key: identifier)
        }
        
    }
    
    /**
     下载完毕后调用
     参数：lication 临时文件的路径（下载好的文件）
     */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        // 获取当前任务响应信息
        if let identifier = downloadTask.currentRequest?.identifier, let responder = getTask(identifier: identifier) {
            // 获取存储文件路径
            if let path = responder.destinationURL, let fileName = downloadTask.response?.suggestedFilename {
                
                let destination = path.appendingPathComponent(fileName)
                
                do {
                    // 存在有旧文件，就先移除
                    if fileManager.fileExists(atPath: destination.path) {
                        try fileManager.removeItem(at: destination)
                    }
                    
                    // 移动文件到目标路径
                    try fileManager.moveItem(at: location, to: destination)
                    
                    // 更新文件位置
                    responder.fileURL = destination
                    
                    // 下载完成后移除任务
                    self.updateTask(resnponder: responder, state: .finish)
                    
                }
                catch {
                    print(error)
                }
                
            }
        }
        
    }
    /**
     每当下载完一部分时就会调用（可能会被调用多次）
     参数：
     bytesWritten 这次调用下载了多少
     totalBytesWritten 累计写了多少长度到沙盒中了
     totalBytesExpectedToWrite 文件总大小
     */
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // 获取当前任务响应信息
        if let identifier = downloadTask.currentRequest?.identifier, let responder = getTask(identifier: identifier) {
            // 获取当前任务的下载进度
            // 重写downloadTask（重启的任务task可能会丢失,同时借此机会去更新文件名)
            responder.downloadTask = downloadTask
            
            responder.progress.totalUnitCount = totalBytesExpectedToWrite
            responder.progress.completedUnitCount = totalBytesWritten
            
            // 回调出去
            if let progressHandler = responder.progressHandler {
                progressHandler(responder.progress)
            }
            
            // 刷新任务状态（写入下载进度、文件名等信息）
            self.updateTask(resnponder: responder)
        }
        
    }
    
}


//public extension FunAlamofire {
//    var downloadResponder: FunDownloadManager.Responder? {
//        
////        if let task = task {
//            
////            let responder = FunDownloadManager.default.buildResponder(request: request)
////
////            responder?.destinationURL = task.destinationURL
////
////            return responder
////        }
//        
//        return nil
//        
//    }
//    
//    
//}
