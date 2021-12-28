//
//  Token.swift
//
//  Created by Nikola Nikolic on 4/16/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

public struct Token {
    public let value: String
    public let expiration: Date
    
    public var isValid: Bool {
        expiration > Date()
    }
    
    public init(value: String, expiration: Date) {
        self.value = value
        self.expiration = expiration
    }
}
