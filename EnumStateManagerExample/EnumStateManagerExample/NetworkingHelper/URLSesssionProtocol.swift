//
//  URLSesssionProtocol.swift
//  EnumStateManagerExample
//
//  Created by JerryWang on 2018/3/19.
//  Copyright © 2018年 JerryWang. All rights reserved.
//

import Foundation

typealias responseCompletionHandler = (_ data: Data?, _ response:  URLResponse?,_ url: URL,_ error: Error?) -> Swift.Void

protocol URLSessionDataTaskProtocol {
    func resume()
    func resumeAndAppendToTaskList<T>(of: T.Type)
}

extension URLSessionDataTask: URLSessionDataTaskProtocol{ }

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (responseCompletionHandler)) -> URLSessionDataTaskProtocol
}

// MARK: - URLSession extension
extension URLSession : URLSessionProtocol{
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (responseCompletionHandler)) -> URLSessionDataTaskProtocol {
        
        let task = dataTask(with: request) { (data, response, error) in
            guard let url = request.url else {return}
            DispatchQueue.main.async { completionHandler(data, response, url, error) }
        }
        return (task as URLSessionDataTaskProtocol)
    }
}

var urlSessiontaskPool = [String: [URLSessionDataTask]]()

extension URLSessionDataTask{
    
    func resumeAndAppendToTaskList<T>(of: T.Type) {
        let identifier = String(describing: T.self)
        if urlSessiontaskPool[identifier] == nil {
            urlSessiontaskPool[identifier] = [self]
        } else {
            urlSessiontaskPool[identifier]?.append(self)
        }
        resume()
    }
    
    static func cancelAllTaskList<T>(of: T.Type) {
        let identifier = String(describing: T.self)
        guard let tasks = urlSessiontaskPool[identifier] else {return}
        tasks.forEach { $0.cancel() }
    }
}
