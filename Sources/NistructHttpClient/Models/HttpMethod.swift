//
//  HttpMethod.swift
//
//  Created by Nikola Nikolic on 3/19/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

/**
 Http Method.
 */
public enum HttpMethod: String {
    
    /// GET method.
    case get    = "GET"
    
    /// POST method.
    case post   = "POST"
    
    /// DELETE Method.
    case delete = "DELETE"
    
    /// PUT method.
    case put    = "PUT"
    
    /// PATCH method.
    case patch  = "PATCH"
}
