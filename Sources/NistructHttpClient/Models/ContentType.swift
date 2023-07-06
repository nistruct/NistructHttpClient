//
//  ContentType.swift
//
//  Created by Nikola Nikolic on 3/19/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

public enum ContentType: String {
    case json           = "application/json"
    case urlEncoded     = "application/x-www-form-urlencoded"
    case multipart      = "multipart/form-data"
}
