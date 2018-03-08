//
//  JSONManager.swift
//  EnumStateManagerExample
//
//  Created by JerryWang on 2018/3/5.
//  Copyright © 2018年 JerryWang. All rights reserved.
//

import Foundation

typealias ResultCompletionHandler<T: Codable> = (ResponseState<T>)->()
typealias responseContent = (data: Data?, response:  URLResponse?, url: URL, error: Error?)

protocol ResponseManager {
    ///Response check
    static func handle<T>(with response: responseContent, model: T.Type, completionHandler: ResultCompletionHandler<T>)
}

extension ResponseManager {
    static func handle<T>(with responseContent: responseContent, model: T.Type, completionHandler: ResultCompletionHandler<T>) {

        guard responseContent.error == nil else {
            completionHandler(ResponseState.failure(NetworkingError.error(responseContent.error!)))
            return
        }
        guard let response = responseContent.response, let data = responseContent.data else {
            completionHandler(ResponseState.failure(NetworkingError.responseAndDataNil))
            return
        }
        guard responseContent.url == response.url else {
            completionHandler(ResponseState.failure(NetworkingError.urlDismatch))
            return
        }
        // MARK: - For Bump
        guard 200...299 ~= (response as! HTTPURLResponse).statusCode else {
            guard let errorMessage = try? JSONDecoder().decode(ErrorModel.self, from: data) else{
                completionHandler(ResponseState.failure(NetworkingError.errorMessageJSONParseFail))
                return
            }
            completionHandler(ResponseState.failure(NetworkingError.othersError(errorMessage.message)))
            return
        }
        
        //success part
        guard let parameters = try? JSONDecoder().decode(T.self, from: data) else{
            completionHandler(ResponseState.failure(NetworkingError.jsonParseFail))
            return
        }
        completionHandler(ResponseState.success(parameters))
    }
}
