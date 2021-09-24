//
//  HttpEndpoint.swift
//
//  Created by Nikola Nikolic on 3/18/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

public protocol HttpEndpoint {
    var path: String { get }
    var method: HttpMethod { get }
    var headers: [String: String]? { get }
    var contentType: ContentType { get }
    var authorizationType: AuthType { get }
}

public extension HttpEndpoint {
    func urlRequest(baseURL: String,
                    body: [String: AnyObject]? = nil,
                    authorizationHeader: String? = nil) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw HttpError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        var headerFields = headers ?? [String: String]()
        headerFields[HttpHeader.ContentType] = contentType.rawValue
        headerFields[HttpHeader.UserAgent] = userAgentValue()
        
        if let authHeader = authorizationHeader {
            headerFields[HttpHeader.Authorization] = "\(authorizationType) \(authHeader)"
        }
        request.allHTTPHeaderFields = headerFields
        request.httpBody = try data(from: body)
        return request
    }
    
    func urlRequest(baseURL: String,
                    body: [String: AnyObject]? = nil) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw HttpError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        var allHeaders: [String: String] = headers ?? [:]
        allHeaders[HttpHeader.ContentType] = contentType.rawValue
        allHeaders[HttpHeader.UserAgent] =  userAgentValue()
        request.allHTTPHeaderFields = allHeaders
        
        request.httpBody = try data(from: body)
        return request
    }
    
    func printRequest(body: [String: AnyObject]? = nil) {
        print("\n****REQUEST****")
        print("Path: \(path)")
        print("Method: \(method)")
        
        if let body = body, !body.isEmpty {
            print("Body:")
            body.forEach {
                print("\($0.key): \($0.value)")
            }
        }
    }
}

private extension HttpEndpoint {
    func data(from params: [String: AnyObject]? = nil) throws -> Data? {
        guard let params = params else {
            return nil
        }
        
        switch contentType {
        case .Json:
            return try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        case .UrlEncoded:
            let parameterArray = params.map { (key, value) -> String in
                        return "\(key)=\(value)"
                    }
            return parameterArray.joined(separator: "&").data(using: .utf8)
        }
    }
}

private extension HttpEndpoint {
    func userAgentValue() -> String {
        "ios;\(Device.appVersion)"
    }
}

// MARK: - Default values

public extension HttpEndpoint {
    var contentType: ContentType {
        return .Json
    }
    
    var authorizationType: AuthType {
        return .Bearer
    }
}
