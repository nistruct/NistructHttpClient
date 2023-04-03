//
//  Token.swift
//
//  Created by Nikola Nikolic on 4/16/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

public protocol Token: Codable {
    var value: String { get }
    var expiration: Date { get }    
    var isValid: Bool { get }
}

public extension Token {
    var isValid: Bool  {
        expiration > Date()
    }
}
