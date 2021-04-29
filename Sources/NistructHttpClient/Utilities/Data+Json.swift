//
//  Data+Json.swift
//
//  Created by Nikola Nikolic on 2/1/21.
//  Copyright © 2021 Nistruct. All rights reserved.
//

import Foundation

extension Data {
    func toJson() -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
            return nil
        }
        return String(prettyPrintedString)
    }
}
