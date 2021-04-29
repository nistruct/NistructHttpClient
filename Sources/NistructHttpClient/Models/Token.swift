//
//  Token.swift
//
//  Created by Nikola Nikolic on 4/16/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

public struct Token {
    let value: String
    let expiration: Date
    
    var isValid: Bool {
        expiration > Date()
    }
}
