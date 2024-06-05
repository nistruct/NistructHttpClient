//
//  ContentType.swift
//
//  Created by Nikola Nikolic on 3/19/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

/**
 Content type.
 */
public enum ContentType: Equatable {
    
    /// Json.
    case json
    
    /// URL encoded.
    case urlEncoded
    
    /// Multipart form data.
    case multipart
    
    /// Custom type.
    case custom(value: String)
    
    /**
     Raw value of the content type.
     */
    public var rawValue: String {
        switch self {
        case .json:
            "application/json"
        case .urlEncoded:
            "application/x-www-form-urlencoded"
        case .multipart:
            "multipart/form-data"
        case .custom(let value):
            value
        }
    }
}
