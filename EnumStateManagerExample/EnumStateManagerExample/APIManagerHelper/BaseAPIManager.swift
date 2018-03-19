//
//  BaseAPIManager.swift
//  EnumStateManagerExample
//
//  Created by JerryWang on 2018/3/3.
//  Copyright © 2018年 JerryWang. All rights reserved.
//

import Foundation

// MARK: - Handle url, parameters, header, method
enum ServiceAPI {
    //URL
    case httpBinURL(BaseURLEndpoint)
    
    //Endpoint(parameter, header)
    enum BaseURLEndpoint {
        case getMethod(key1: String, key2: String, header: String)
        case postMethod(key1: String, key2: String)
        
        fileprivate var rawValue : String {
            switch self {
            case .getMethod: return "/get"
            case .postMethod: return "/post"
            }
        }
        
        fileprivate func fetchGetMethodParameters(key1: String, key2: String, header: String)->(parameters: [String : Any], header: [String: String]) {
            return (parameters: ["key1" : key1, "key2": key2 ], header: ["header": header])
        }
    }
    
    ///Combinate all urls with their own endpoint.
    fileprivate func urlBuilder() -> String {
        switch self {
        case .httpBinURL(let endpoint):
            return "https://httpbin.org" + endpoint.rawValue
        }
    }
}

extension ServiceAPI: APIEndPointProtocol {
    func provideValues() -> (url: String, httpMethod: URLRequest.HTTPVerb, parameters: [String : Any]?, header: [String : String]?, contentType: URLRequest.ContentType) {
        switch self {
        case .httpBinURL(let endPoint):
            switch endPoint {
            
            case .getMethod(key1: let value1, key2: let value2, header: let headerValue):
                let results = endPoint.fetchGetMethodParameters(key1: value1, key2: value2, header: headerValue)
                return (url: ServiceAPI.httpBinURL(endPoint).urlBuilder(), httpMethod: .GET, parameters: results.parameters, header: results.header, contentType: .others)
            
            case .postMethod(key1: let value1, key2: let value2):
                return (url: endPoint.rawValue, httpMethod: .POST, parameters: nil, header: nil, contentType: .json)
            }
        }
    }
}
