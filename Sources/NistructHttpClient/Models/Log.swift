//
//  Log.swift
//  
//  Created by Nikola Nikolic on 11.10.22..
//  Copyright © 2020 Nistruct. All rights reserved.
//

import NistructLog

typealias log = NistructLog

/**
 Log.
 */
class Log {
    
    /**
     Starts the logging.
     */
    static func start() {
        log.configure()
        log.setLogLevel(.verbose)
    }
}
