//
//  FunAlamofire+Codable.swift
//  FunAlamofire
//
//  Created by 肖华 on 2022/2/18.
//

import Foundation
public extension FunAlamofire.Task {
    
    func mapObject<T: Codable>(_ type: T.Type, completion: ((T)-> Void)?) -> FunAlamofire.Task {
        // 获取json对象
        return mapJSON { json in
            do {
                // 将json对象转换成data
                let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                
                let decoder = JSONDecoder()
                // json解析
                let object = try decoder.decode(T.self, from: data)
                
                completion?(object)
            }

            catch{
                debugPrint(error.localizedDescription)
            }

        }

    }

}
