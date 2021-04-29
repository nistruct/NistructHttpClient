//
//  Notification+Http.swift
//
//  Created by Nikola Nikolic on 29.4.21..
//  Copyright © 2021 Nistruct. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let UpdateNeeded         = Notification.Name("APP_NEEDS_UPDATE")
    static let InvalidCertificate   = Notification.Name("INVALID_CERTIFICATE")
    static let MissingCertificate   = Notification.Name("MISSING_CERTIFICATE")
}
