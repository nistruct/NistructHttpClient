//
//  FileType.swift
//  
//  Created by Nikola Nikolic on 6.7.23..
//  Copyright © 2023 Nistruct. All rights reserved.
//

import Foundation

/**
 The list of document types.
 */
public enum FileType {
    
    /// PDF type.
    case pdf
    
    /// Text type.
    case txt
    
    /// Image type.
    case image(type: ImageType)
    
    /// XML type.
    case xml
    
    /// JSON type.
    case json
    
    /// Undefined type. This is used to avoid including unsupported files in the app.
    case undefined
    
    /// The raw value.
    var rawValue: String {
        switch self {
        case .pdf: return "pdf"
        case .txt: return "txt"
        case .xml: return "xml"
        case .json: return "json"
        case .image(let imageType): return imageType.rawValue
        case .undefined: return "undefined"
        }
    }
    
    var rawMimeType: String {
        switch self {
        case .image(let type):
            return "image/\(type.rawMimeType)"
        case .pdf:
            return "application/pdf"
        case .txt:
            return "text/plain"
        case .json:
            return "application/json"
        case .xml:
            return "application/xml" // or "text/xml"
        default:
            return rawValue
        }
    }
    
    var isUndefined: Bool {
        switch self {
        case .undefined: return true
        default: return false
        }
    }
    
    /**
     A raw value initialiser.
     */
    init?(rawValue: String) {
        switch rawValue {
        case FileType.pdf.rawValue:
            self = .pdf
        case FileType.txt.rawValue:
            self = .txt
        case FileType.xml.rawValue:
            self = .xml
        case FileType.json.rawValue:
            self = .json
        case ImageType.jpg.rawValue,
             ImageType.jpeg.rawValue,
             ImageType.png.rawValue,
             ImageType.gif.rawValue:
            if let imageType = ImageType(rawValue: rawValue) {
                self = .image(type: imageType)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

/**
 The list of document image types.
 */
public enum ImageType: String, Decodable {
    
    /// Image raw values
    var rawMimeType: String {
        switch self {
        case .jpg:
            return "jpeg"
        default:
            return rawValue
        }
    }
    
    /// JPG image type.
    case jpg
    
    /// JPEG image type.
    case jpeg
    
    /// PNG image type.
    case png
    
    /// GIF image type.
    case gif
}
