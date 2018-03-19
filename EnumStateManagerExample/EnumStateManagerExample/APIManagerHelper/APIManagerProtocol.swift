//
//  BaseAPIManager.swift
//  BumpTwo
//
//  Created by JerryWang on 2018/1/28.
//  Copyright © 2018年 Jerrywang. All rights reserved.
//

import UIKit

// MARK: - URLs implementation protocol
///All URL layer need to implement this protocol
protocol APIEndPointProtocol {
    func provideValues()-> (url: String, httpMethod: URLRequest.HTTPVerb, parameters:[String:Any]?, header: [String: String]? ,contentType: URLRequest.ContentType)
    var url: String { get }
    var httpVerb: URLRequest.HTTPVerb { get }
    var parameters: [String: Any]? { get }
    var header: [String: String]? { get }
    var contentType: URLRequest.ContentType { get }
}

extension APIEndPointProtocol {
    var url: String { return provideValues().url }
    var httpVerb: URLRequest.HTTPVerb { return provideValues().httpMethod }
    var parameters: [String: Any]? { return provideValues().parameters }
    var header: [String: String]? { return provideValues().header }
    var contentType: URLRequest.ContentType { return provideValues().contentType }
}

