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
    var kind: RequestKind { get }
    var components: [MultipartComponent]? { get }
}

public extension HttpEndpoint {
    var contentType: ContentType { .json }
    var kind: RequestKind { .api }
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
        
        if let authorizationHeader {
            headerFields[HttpHeader.Authorization] = authorizationHeader.value
        }
        
        request.allHTTPHeaderFields = headerFields
        request.httpBody = try data(from: body)
        return request
    }
    
    func multipartRequest(baseURL: String,
                          body: [String: AnyObject] = [:],
                          authorizationHeader: AuthorizationHeader? = nil) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw HttpError.invalidURL
        }
        
        var multipart = MultipartRequest()
        
        for field in body {
            multipart.add(key: field.key, value: field.value)
        }
        
        if let components {
            for component in components {
                switch component {
                case .text(let data, let name):
                    multipart.add(key: name, value: data)
                case .file(let data, let name, let fileName, let type):
                    multipart.add(key: name, fileName: fileName, fileMimeType: type.rawMimeType, fileData: data)
                case .image(let data, let name, let fileName, let type):
                    multipart.add(key: name, fileName: fileName, fileMimeType: type.rawMimeType, fileData: data)
                }
            }
        }

        /// Create a regular HTTP URL request & use multipart components
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: HttpHeader.ContentType)
        request.httpBody = multipart.httpBody
        
        var headerFields = headers ?? [String: String]()
        headerFields[HttpHeader.UserAgent] =  userAgentValue()
        headerFields[HttpHeader.ContentType] = contentType.rawValue
        
        if let authorizationHeader {
            headerFields[HttpHeader.Authorization] = authorizationHeader.value
        }
        
        request.allHTTPHeaderFields = headerFields
        
        return request
    }
    
    func printRequest(url: String, body: [String: AnyObject]? = nil) {
        var bodyInfo = ""
        if let body = body, !body.isEmpty {
            body.forEach {
                bodyInfo.append("\($0.key): \($0.value)\n")
            }
        }
        
        var info = """
                \n****REQUEST****
                \(method) \(url)\(path)"
                Body:
                \(bodyInfo)
                """
        
        if let components {
            var multipartInfo = ""
            components.forEach {
                multipartInfo.append($0.description)
            }
            
            info += """
                Multipart components:
                \(multipartInfo)
                """
        }
        
        log.debug(info)
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
