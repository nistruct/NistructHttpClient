//
//  HttpHeader.swift
//
//  Created by Nikola Nikolic on 3/19/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

public struct HttpHeader {
    public static let ContentType   = "Content-Type"
    public static let ContentLength = "Content-Length"
    public static let Accept        = "Accept"
    public static let Authorization = "Authorization"
    public static let Bearer        = AuthType.bearer.rawValue
    public static let Basic         = AuthType.basic.rawValue
    public static let UserAgent     = "User-Agent"
    
    public enum AuthType: String {
        case bearer = "Bearer"
        case basic  = "Basic"
    }
}

public enum AuthorizationHeader {
    case bearer(token: String)
    case basic(token: String)
    
    var value: String {
        switch self {
        case .bearer(let token): return HttpHeader.AuthType.bearer.rawValue + " " + token
        case .basic(let token): return HttpHeader.AuthType.basic.rawValue + " " + token
        }
    }
}
