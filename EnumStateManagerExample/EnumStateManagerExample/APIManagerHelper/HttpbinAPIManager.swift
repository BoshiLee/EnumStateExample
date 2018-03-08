//
//  HttpbinAPIManager.swift
//  EnumStateManagerExample
//
//  Created by JerryWang on 2018/3/4.
//  Copyright © 2018年 JerryWang. All rights reserved.
//

import Foundation

// MARK: - Public method for HttpbinAPI
struct HttpbinAPIManager: ResponseManager {
    
    static func fetchGetMethodContents<T>(key1: String, key2: String, header: String, model: T.Type, _ completionHandler: @escaping ResultCompletionHandler<T>) -> URLSessionDataTask {
        
        let task = HTTPService.generateRequest(with: ServiceAPI.httpBinURL(.getMethod(key1: key1, key2: key2, header: header))).dataTask { (data, response, url, error) in
            self.handle(with: (data, response, url, error), model: model, completionHandler: completionHandler)
        }
        return task
    }
}
