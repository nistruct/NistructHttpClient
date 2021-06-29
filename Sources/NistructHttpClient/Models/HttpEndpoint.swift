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
}

public extension HttpEndpoint {
    func urlRequest(baseURL: String,
                    body: [String: AnyObject]? = nil,
                    authorizationHeader: String? = nil,
                    authorizationHeaderType: HttpHeader.AuthType = .Bearer) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw HttpError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let authHeader = authorizationHeader {
            var headerFields = headers ?? [String: String]()
            headerFields[HttpHeader.Authorization] = "\(authorizationHeaderType) \(authHeader)"
            headerFields[HttpHeader.UserAgent] =  userAgentValue()
            request.allHTTPHeaderFields = headerFields
        } else {
            var headerFields = headers ?? [String: String]()
            headerFields[HttpHeader.UserAgent] = userAgentValue()
            request.allHTTPHeaderFields = headerFields
        }
                
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
        return try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
    }
}

private extension HttpEndpoint {
    func userAgentValue() -> String {
        "ios;\(Device.appVersion)"
    }
}
