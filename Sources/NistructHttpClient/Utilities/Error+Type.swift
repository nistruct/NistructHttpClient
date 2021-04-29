//
//  Error+Type.swift
//
//  Created by Nikola Nikolic on 12/11/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

extension Error {
    func isNoInternet() -> Bool {
        let nsError: NSError = self as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorNotConnectedToInternet {
            return true
        }
        return false
    }
}
