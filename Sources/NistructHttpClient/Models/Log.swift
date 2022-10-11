//
//  Log.swift
//  
//
//  Created by Nikola Nikolic on 11.10.22..
//

import NistructLog

typealias log = NistructLog

class Log {
    static func start() {
        log.configure()
        log.setLogLevel(.verbose)
    }
}
