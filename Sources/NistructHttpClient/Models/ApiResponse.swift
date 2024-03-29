//
//  ApiResponse.swift
//
//  Created by Nikola Nikolic on 10/19/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

public struct ApiResponse<Data: Decodable>: Decodable {
    var statusCode: Int?
    let status: String?
    let message: String?
    let data: Data?
    let errorInfo: ApiErrorInfo?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let statusCodeValue = try container.decodeIfPresent(Int.self, forKey: .statusCode)
        statusCode = statusCodeValue
        
        status = try container.decodeIfPresent(String.self, forKey: .status)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        
        let dataValue = try container.decodeIfPresent(Data.self, forKey: .data)
        
        if dataValue == nil && statusCodeValue == 200,
           let empty = "{}".data(using: .utf8),
           let emptyData = try? JSONDecoder().decode(Data.self, from: empty) {
            data = emptyData
        } else {
            data = dataValue
        }
        
        if let errorCode = try container.decodeIfPresent(String.self, forKey: .errorCode),
           let errorMsg = try container.decodeIfPresent(String.self, forKey: .errorMessage) {
            errorInfo = ApiErrorInfo(code: errorCode, message: errorMsg)
        } else {
            errorInfo = try container.decodeIfPresent(ApiErrorInfo.self, forKey: .errorCode)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case statusCode
        case status
        case message
        case data
        case errorCode      = "error"
        case errorMessage   = "error_description"
    }
}

struct ApiErrorInfo: Decodable {
    let code: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code       = "error"
        case message    = "error_description"
    }
}
