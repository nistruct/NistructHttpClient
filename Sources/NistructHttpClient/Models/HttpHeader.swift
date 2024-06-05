//
//  HttpHeader.swift
//
//  Created by Nikola Nikolic on 3/19/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

/**
 HTTP headers.
 */
public struct HttpHeader {
    
    /// Contenty-Type.
    public static let ContentType           = "Content-Type"
    
    /// Content-Length.
    public static let ContentLength         = "Content-Length"
    
    /// Content-Disposition.
    public static let ContentDisposition    = "Content-Disposition"
    
    /// Accept.
    public static let Accept                = "Accept"
    
    /// Authorization.
    public static let Authorization         = "Authorization"
    
    /// Bearer.
    public static let Bearer                = AuthType.bearer.rawValue
    
    /// Basic.
    public static let Basic                 = AuthType.basic.rawValue
    
    /// User-Agent.
    public static let UserAgent             = "User-Agent"
    
    /**
     Auth type.
     */
    public enum AuthType: String {
        
        /// Bearer.
        case bearer = "Bearer"
        
        /// Basic.
        case basic  = "Basic"
    }
}

/**
 Authorization Header.
 */
public enum AuthorizationHeader {
    
    /// Bearer with token value.
    case bearer(token: String)
    
    /// Basic with token value.
    case basic(token: String)
    
    /// Raw value.
    var value: String {
        switch self {
        case .bearer(let token): return HttpHeader.AuthType.bearer.rawValue + " " + token
        case .basic(let token): return HttpHeader.AuthType.basic.rawValue + " " + token
        }
    }
}

/**
 Authorization Type.
 */
public enum AuthorizationType {
    
    /// No authorization.
    case no
    
    /// Basic authorization with token.
    case basic(token: String)
    
    /// Client authorization.
    case client
    
    /// Access authorization.
    case access
}
