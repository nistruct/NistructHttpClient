//
//  Error+Utils.swift
//
//  Created by Nikola Nikolic on 3/19/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

extension Error {
    var errorInformation: Error? {
        let nsError = self as NSError
        if noInternet {
            return self
        }
        return nsError.userInfo[NSUnderlyingErrorKey] as? Error
    }
    
    var timeout: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut
    }
    
    var noInternet: Bool {
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet
    }
}
