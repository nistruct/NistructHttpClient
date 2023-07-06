//
//  MultipartComponent.swift
//
//  Created by Nikola Nikolic on 6.7.23..
//  Copyright © 2023 Nistruct. All rights reserved.
//

import Foundation

public enum MultipartComponent {
    
    /// Text part of multipart body. Usually JSON encoded data.
    case text(data: Data, name: String)
    
    /// Image part of multipart body.
    case image(data: Data, name: String, fileName: String, imageType: ImageType)
    
    /// File part of multipart body.
    case file(data: Data, name: String, fileName: String, fileType: FileType)
}

extension MultipartComponent: CustomStringConvertible {    
    public var description: String {
        switch self {
        case .text(_, let name):
            return "text(name: \(name))"
        case .file(_, let name, let fileName, let type):
            return "file(name: \(name), fileName: \(fileName), mimeType: \(type.rawMimeType))"
        case .image(_, let name, let fileName, let type):
            return "file(name: \(name), fileName: \(fileName), mimeType: \(type.rawMimeType))"
        }
    }
    
}
