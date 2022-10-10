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
}

public extension HttpEndpoint {
    var contentType: ContentType { .json }
}

public extension HttpEndpoint {
    func urlRequest(baseURL: String,
                    body: [String: AnyObject]? = nil,
                    authorizationHeader: AuthorizationHeader? = nil) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw HttpError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        var headerFields = headers ?? [String: String]()
        headerFields[HttpHeader.UserAgent] =  userAgentValue()
        headerFields[HttpHeader.ContentType] = contentType.rawValue
        
        if let authHeader = authorizationHeader {
            headerFields[HttpHeader.Authorization] = authHeader.value
        }
        
        request.allHTTPHeaderFields = headerFields
        request.httpBody = try data(from: body)
        return request
    }
    
    func printRequest(url: String, body: [String: AnyObject]? = nil) {
        print("\n****REQUEST****")
        print("Path: \(url)\(path)")
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
        case .json:
            return try JSONSerialization
                .data(withJSONObject: params, options: JSONSerialization.WritingOptions())
        case .urlEncoded:
            return params
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
                .data(using: .utf8)
        }
    }
}

private extension HttpEndpoint {
    func userAgentValue() -> String {
        "ios;\(Device.appVersion)"
    }
}
