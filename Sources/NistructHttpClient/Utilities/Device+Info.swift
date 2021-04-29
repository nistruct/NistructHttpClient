//
//  Device+Info.swift
//
//  Created by Nikola Nikolic on 8/6/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import UIKit

struct Device {
    static var osVersion: String {
        UIDevice.current.systemVersion
    }
    
    static var appVersionAndBundle: String {
        let version = Bundle.main.infoDictionary?[PlistKeys.BundleShortVersion] as? String ?? Constants.Unknown
        let bundle = Bundle.main.infoDictionary?[PlistKeys.BundleVersion] as? String ?? Constants.Unknown
        
        return "\(version) (\(bundle))"
    }
    
    static var appVersion: String {
        Bundle.main.infoDictionary?[PlistKeys.BundleShortVersion] as? String ?? Constants.Unknown
    }
}

private struct PlistKeys {
    static let BundleVersion        = "CFBundleVersion"
    static let BundleShortVersion   = "CFBundleShortVersionString"
}

private struct Constants {
    static let Unknown  = "unknown"
}
