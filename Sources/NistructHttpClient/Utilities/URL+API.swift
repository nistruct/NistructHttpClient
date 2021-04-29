//
//  URL+API.swift
//
//  Created by Nikola Nikolic on 3/20/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

extension URL {
    static func url(withPath path: String, relativeTo basePath: String) -> URL {
        if !path.hasPrefix("/") {
            return URL(string: "\(basePath)/\(path)")!
        }
        return URL(string: "\(basePath)\(path)")!
    }
    
    func urlByAppendingQueryParameters(_ params: [String: String]?) -> URL {
        guard let params = params, var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }
        components.queryItems = params.map { return URLQueryItem(name: $0.0, value: $0.1) }
        
        if let url = components.url {
            print(url.absoluteString)
            return url
        }
        
        return self
    }
}
