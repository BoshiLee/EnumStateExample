//
//  NetworkingRequestHelper.swift
//  EnumStateManagerExample
//
//  Created by JerryWang on 2017/2/27.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import Foundation

fileprivate extension Dictionary{
    
    func isContainFiles() -> Bool{
        var result = false
        
        for (_, value) in self{
            if value is Upload{
                result = true
            }
        }
        return result
    }
    
    //拿出參數
    func getParameters() -> Dictionary<String, Any>?{
        var parameter : Dictionary<String, Any>? = [:]
        
        for (key, value) in self{
            guard let key = key as? String else{break}
            if !(value is Upload){
                parameter?[key] = value
            }
        }
        return parameter
    }
    
    //拿出Data
    func getDatas() -> Dictionary<String, Any>?{
        
        var parameter : Dictionary<String, Any>? = [:]
        
        for (key, value) in self{
            guard let key = key as? String else{break}
            if (value is Upload){
                parameter?[key] = value
            }
        }
        
        return parameter
    }
    
    func buildParams() -> String {
        
        var components: [(String, String)] = []
        
        var parameters = [String: Any]()
        
        for (key, value) in self{
            guard let key = key as? String else{break}
            parameters[key] = value
        }
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((escape(key), escape((value.boolValue ? "1" : "0"))))
            } else {
                components.append((escape(key), escape("\(value)")))
            }
        } else if let bool = value as? Bool {
            components.append((escape(key), escape((bool ? "1" : "0"))))
        } else {
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    
    
    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}

fileprivate extension Data {
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

fileprivate extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}

fileprivate struct Upload {
    var mimeType: URLRequest.HTTPMimeType?
    var data: Data?
    var fileName: String?
    
    init(data: Data, fileName: String, mimeType: URLRequest.HTTPMimeType) {
        self.data = data
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

extension URLRequest{
    
    fileprivate init?(urlString: String) {
        if let url = URL(string: urlString) {
            self.init(url: url)
        } else {
            return nil
        }
    }
    // MARK: - Public option
    ///Content Type for URLRequest
    enum ContentType : String{
        case json = "application/json"
        case formData = "multipart/form-data"
        case urlencoded = "application/x-www-form-urlencoded"
        case others = ""
    }
    ///HttpVerb for URLRequest
    enum HTTPVerb: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case HEAD = "HEAD"
        case DELETE = "DELETE"
        case PATCH = "PATCH"
        case OPTIONS = "OPTIONS"
        case TRACE = "TRACE"
        case CONNECT = "CONNECT"
        case UNKNOWN = "UNKNOWN"
    }
    ///HTTPMimeType for URLRequest
    enum HTTPMimeType : String {
        case imageJpeg = "image/jpeg"
        case imagePng = "image/png"
    }
    ///HTTPSerialize for URLRequest
    enum HTTPSerialize{
        case HTTPParameterSerializer //其他都選這個
        case JSONParameterSerializer //body以json包
    }
    
    fileprivate var contentTypeKey: String {
        return "Content-Type"
    }
    
    fileprivate var httpVerb: HTTPVerb {
        set {
            httpMethod = newValue.rawValue
        }
        get {
            if let verb = HTTPVerb(rawValue: httpMethod!) {
                return verb
            }
            return .UNKNOWN
        }
    }
    
    fileprivate mutating func appendParameters(_ parameters: [String: Any], requestType: URLRequest.ContentType) {
        
        if (httpVerb == .GET || httpVerb == .HEAD || httpVerb == .DELETE) {
            appendParametersAsQueryString(parameters)
        }else{
            switch requestType {
            case .formData:
                appendParametersAsMultiPartFormData(parameters)
            case .urlencoded:
                appendParametersAsUrlEncoding(parameters)
            case .others:
                appendParametersAsQueryString(parameters)
            default:
                break
            }
            
        }
    }
    
    //get head delete http
    fileprivate mutating func appendParametersAsQueryString(_ parameters: [String: Any]){
        
        var urlComponents = URLComponents(string: (url?.absoluteString)!)!
        urlComponents.queryItems = []
        
        for (key, value) in parameters{
            guard let value = value as? String else{return}
            urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        
        guard let queryedURL = urlComponents.url else{return}
        
        url = queryedURL
        
    }
    
    //post http formData
    fileprivate mutating func appendParametersAsMultiPartFormData(_ parameters: [String: Any]) {
        
        let pureParameters = parameters.getParameters()
        let dataParameters = parameters.getDatas()
        
        let boundary = "Boundary+\(arc4random())\(arc4random())"
        
        setValue("\(ContentType.formData.rawValue); boundary=\(boundary)",
            forHTTPHeaderField: contentTypeKey)
        
        var body = Data()
        
        if pureParameters != nil {
            for (key, value) in pureParameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        if dataParameters != nil{
            for (key, value) in dataParameters! {
                guard let value = value as? Upload else{return}
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(value.fileName!)\"\r\n")
                body.appendString(string: "Content-Type: \(value.mimeType!.rawValue)\r\n\r\n")
                body.append(value.data!)
                body.appendString(string: "\r\n")
                
            }
        }
        body.appendString(string: "--\(boundary)--\r\n")
        httpBody = body
    }
    
    fileprivate mutating func appendParametersAsUrlEncoding(_ parameters: [String: Any]) {
        
        if value(forHTTPHeaderField: contentTypeKey) == nil {
            var contentStr = "\(ContentType.urlencoded.rawValue)"
            if let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)) {
                contentStr += "; charset=\(charset)"
            }
            setValue(contentStr, forHTTPHeaderField:contentTypeKey)
        }
        let queryString = parameters.buildParams()
        httpBody = queryString.data(using: String.Encoding.utf8)
        
    }
    
    //post json (若選成get, 則變成get http)
    fileprivate mutating func appendParametersAsJSON(_ parameters: [String: Any]) {
        
        if (httpVerb == .GET || httpVerb == .HEAD || httpVerb == .DELETE) {
            appendParametersAsQueryString(parameters)
        } else {
            do {
                httpBody = try JSONSerialization.data(withJSONObject: parameters as AnyObject, options: JSONSerialization.WritingOptions())
            } catch let error {
                print(error)
            }
            var contentStr = ContentType.json.rawValue
            if let charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)) {
                contentStr += "; charset=\(charset)"
            }
            setValue(contentStr, forHTTPHeaderField: contentTypeKey)
        }
    }
}

fileprivate protocol HTTPSerializeProtocol {
    
    func serialize(_ request: inout URLRequest, parameters: [String: Any], requestType: URLRequest.ContentType)
}

fileprivate struct HTTPParameterSerializer:HTTPSerializeProtocol {

    public func serialize(_ request: inout URLRequest, parameters: [String: Any], requestType: URLRequest.ContentType) {
        request.appendParameters(parameters, requestType: requestType)
    }
}

fileprivate struct JSONParameterSerializer:HTTPSerializeProtocol {
    public func serialize(_ request: inout URLRequest, parameters: [String: Any], requestType: URLRequest.ContentType) {
        request.appendParametersAsJSON(parameters)
        
    }
}

// MARK: - HTTPService
///Generate url request
struct HTTPService{
    private init() {}
    ///requestType:
    ///GET => others,
    ///POST Body type => json "application/json"
    ///formData = "multipart/form-data"
    ///urlencoded = "application/x-www-form-urlencoded"
    static func generateRequest(urlString: String, httpVerb: URLRequest.HTTPVerb = .GET, parameter: [String: Any]? = nil, headers: [String: String]? = nil, requestType: URLRequest.ContentType = .others) -> URLRequest{
        
        var serializer : HTTPSerializeProtocol?
        
        switch requestType {
        case .json:
            serializer = JSONParameterSerializer()
        default:
            serializer = HTTPParameterSerializer()
        }
        
        var request = URLRequest(urlString: urlString)!
        request.httpVerb = httpVerb
        
        if let parameter = parameter {
            serializer?.serialize(&request, parameters: parameter, requestType: requestType)
        }
        
        if let headers = headers {
            for (key,value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
    ///requestType:
    ///GET => others,
    ///POST Body type => json "application/json"
    ///formData = "multipart/form-data"
    ///urlencoded = "application/x-www-form-urlencoded"
    static func generateRequest(with api: APIEndPointProtocol) -> URLRequest{
        let req = generateRequest(urlString: api.url, httpVerb: api.httpVerb, parameter: api.parameters, headers: api.header, requestType: api.contentType)
        return req
    }
}

typealias responseCompletionHandler = (_ data: Data?, _ response:  URLResponse?,_ url: URL,_ error: Error?) -> Swift.Void

// MARK: - datatask extension
extension URLRequest {
    ///return datatask
    func dataTask(responseHandler: @escaping responseCompletionHandler) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: self) { (data, response, error) in
            guard let url = self.url else {return}
            DispatchQueue.main.async { responseHandler(data, response, url, error) }
        }
        return task
    }
}
