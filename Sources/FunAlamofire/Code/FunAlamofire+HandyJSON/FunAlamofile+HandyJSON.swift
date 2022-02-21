//
//  FunAlamofile+HandyJSON.swift
//  Alamofire
//
//  Created by 肖华 on 2022/2/21.
//

import Foundation
import HandyJSON

public extension FunAlamofire.Task {

    func mapObject<T: HandyJSON>(_ type: T.Type, completion: ((T)-> Void)?) -> FunAlamofire.Task {
        return mapJSON { json in
            
            if let json = json as? [String: Any], let obj = T.deserialize(from: json, designatedPath: nil) {
            
                completion?(obj)
            } 
        }
    }
}
