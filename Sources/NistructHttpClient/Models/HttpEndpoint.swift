//
//  HttpEndpoint.swift
//
//  Created by Nikola Nikolic on 3/18/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

/**
 HTTP Endpoint description protocol.
 */
public protocol HttpEndpoint {
    
    /// Relative path.
    var path: String { get }
    
    /// Http Method.
    var method: HttpMethod { get }
    
    /// Headers info.
    var headers: [String: String]? { get }
    
    /// Content type.
    var contentType: ContentType { get }
    
    /// Request kind.
    var kind: RequestKind { get }
    
    /// Mutlipart components.
    var components: [MultipartComponent]? { get }
}

// MARK: - Default implementation of the `HttpEndpoint` protocol.
public extension HttpEndpoint {
    var contentType: ContentType { .json }
    var kind: RequestKind { .api }
    var components: [MultipartComponent]? { nil }
}

// MARK: - Helper methods.
public extension HttpEndpoint {
    
    /**
     Creates an URL request.
     - parameters baseURL: Base URL.
     - parameters body: Optional body.
     - parameters authorizationHeader: Optional authorization header.
     - throws Error of kind`HttpError`.
     - returns Instance of the `URLRequest`.
     */
    func urlRequest(baseURL: String,
                    body: [String: AnyObject]? = nil,
                    authorizationHeader: AuthorizationHeader? = nil) throws -> URLRequest {
        
        if contentType == .multipart {
            return try multipartRequest(baseURL: baseURL, body: body ?? [:], authorizationHeader: authorizationHeader)
        }
        
        guard let url = URL(string: baseURL + path) else {
            throw HttpError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        var headerFields = headers ?? [String: String]()
        headerFields[HttpHeader.UserAgent] =  userAgentValue
        headerFields[HttpHeader.ContentType] = contentType.rawValue
        
        if let authorizationHeader {
            headerFields[HttpHeader.Authorization] = authorizationHeader.value
        }
        
        request.allHTTPHeaderFields = headerFields
        request.httpBody = try data(from: body)
        return request
    }
    
    /**
     Creates a Multipart request.
     - parameters baseURL: Base URL.
     - parameters body: Optional body.
     - parameters authorizationHeader: Optional authorization header.
     - throws Error of kind`HttpError` if the url is invalid.
     - returns Instance of the `URLRequest`.
     */
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

        /// Creates a regular HTTP URL request & uses multipart components.
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: HttpHeader.ContentType)
        request.httpBody = multipart.httpBody
        
        var headerFields = [String: String]()
        headerFields[HttpHeader.UserAgent] =  userAgentValue
        
        if let authorizationHeader {
            headerFields[HttpHeader.Authorization] = authorizationHeader.value
        }
        
        request.allHTTPHeaderFields = headerFields
        
        return request
    }
    
    /**
     Prints the request info.
     - parameter url: Request url.
     - parameter body: Optional body.
     */
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

// MARK: - Private helper methods.
private extension HttpEndpoint {
    
    /**
     Generates a raw bytes Http header.
     - parameter params: Optional body params.
     - throws
     - returns Optional `Data` instance.
     */
    func data(from params: [String: AnyObject]? = nil) throws -> Data? {
        guard let params else {
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
        case .multipart, .custom:
            return nil
        }
    }
    
    /// User-Agent value.
    var userAgentValue: String {
        "ios;\(Device.appVersion)"
    }
}
