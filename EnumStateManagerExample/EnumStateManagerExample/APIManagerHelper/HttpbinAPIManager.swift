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
    
    fileprivate let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchGetMethodContents<T>(key1: String, key2: String, header: String, model: T.Type, _ completionHandler: @escaping ResultCompletionHandler<T>) -> URLSessionDataTaskProtocol {
        
        let request = HTTPService.generateRequest(with: ServiceAPI.httpBinURL(.getMethod(key1: key1, key2: key2, header: header)))
        
        let task = session.dataTask(with: request) { (data, response, url, error) in
            self.handle(with: (data, response, url, error), model: model, completionHandler: completionHandler)
        }  
        return task
    }
}
