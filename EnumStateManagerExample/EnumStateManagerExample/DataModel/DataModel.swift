//
//  DataMondel.swift
//  EnumStateManagerExample
//
//  Created by JerryWang on 2018/3/5.
//  Copyright © 2018年 JerryWang. All rights reserved.
//

import Foundation

struct ResponseParameterModel: Codable {
    let args: ParameterModel

    func formatData() -> [ParameterModel] {
        return [ParameterModel(from: self)]
    }
}

struct ParameterModel: Codable {
    let key1: String
    let key2: String
}

extension ParameterModel {
    init(from response: ResponseParameterModel) {
        key1 = response.args.key1
        key2 = response.args.key2
    }
}

// MARK: - For bump
struct ErrorModel: Codable {
    let message: String
}
