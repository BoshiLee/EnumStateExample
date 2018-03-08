//
//  NetworkError.swift
//  EnumStateManagerExample
//
//  Created by JerryWang on 2018/3/5.
//  Copyright © 2018年 JerryWang. All rights reserved.
//

import Foundation

///Networking Error
enum NetworkingError {
    
    case responseAndDataNil
    case urlDismatch
    case errorMessageJSONParseFail
    case jsonParseFail
    case error(Error)
    case noNetworkingConnect
    case othersError(String)
    
    var rawValue : String {
        switch self {
        case .responseAndDataNil: return "ERROR: Response or Data is nil"
        case .urlDismatch: return "ERROR: RequestURL and ResponseURL dismatch"
        case .errorMessageJSONParseFail: return "ERROR: Error Message JSON parse fail"
        case .jsonParseFail: return "ERROR: JSON parse fail"
        case .error(let error): return "ERROR: \(error.localizedDescription)"
        case .noNetworkingConnect: return "ERROR: No Networking connect"
        case .othersError(let message): return "ERROR: \(message)"
        }
    }
}
