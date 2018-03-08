//
//  ResponseResult.swift
//  EnumStateManagerExample
//
//  Created by JerryWang on 2018/3/6.
//  Copyright © 2018年 JerryWang. All rights reserved.
//

import Foundation
///T: Data model, which is codable conformance
enum ResponseState<T: Codable> {
    case success(T)
    case failure(NetworkingError) //all error message (error, 400, 500)
}
