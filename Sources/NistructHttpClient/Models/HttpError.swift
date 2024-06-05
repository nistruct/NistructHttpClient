//
//  HttpError.swift
//
//  Created by Nikola Nikolic on 3/18/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

/**
 HTTP Error.
 */
public enum HttpError: Error {
    
    /// Incalid URL error.
    case invalidURL
    
    //// Unauthorized error.
    case unauthorized
    
    /// Invalid request error.
    case invalidRequest
    
    /// Unexpected response error.
    case unexpectedResponse
    
    /// Precondition required error.
    case preconditionRequired(message: String?)
    
    /// Not found error.
    case notFound(message: String?)
    
    /// Already done error.
    case alreadyDone(message: String?)
    
    /// Server error.
    case serverError(code: Int, errorCode: String?, message: String?)
    
    /// Parser error.
    case parserError(message: String?)
    
    /// General error.
    case generalError(message: String?)
    
    /// Upgrate required error.
    case upgradeRequired
}

typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

/**
 Http codes.
 */
public extension HTTPCodes {
    static let success              = 200 ..< 300
    static let unauthorized         = 401
    static let preconditionRequired = 428
    static let notFound             = 404
    static let alreadyDone          = 410
    static let upgradeRequired      = 426
}

// MARK: - Helper methods.
extension HttpError {
    
    /**
     Gets an error of type `HttpError` from the status code and response from backend.
     - parameter code: Status code.
     - parameter data: Binary data response.
     - returns Error of type `HttpError`.
     */
    static func error(withCode code: Int, data: Data) -> HttpError? {
        if code == HTTPCodes.unauthorized {
            return HttpError.unauthorized
        }
        
        if code == HTTPCodes.upgradeRequired {
            return HttpError.upgradeRequired
        }
        
        guard !HTTPCodes.success.contains(code) else {
            return nil
        }
        
        guard let error = data.asApiError(code: code) else {
            return nil
        }
        
        return error
    }
}

// MARK: - Helper properties.
extension HttpError {
    
    /// Status code.
    var code: Int {
        switch self {
        case .serverError(let code, _, _): return code
        case .preconditionRequired: return HTTPCodes.preconditionRequired
        case .alreadyDone: return HTTPCodes.alreadyDone
        case .notFound: return HTTPCodes.notFound
        case .unauthorized: return HTTPCodes.unauthorized
        default: return -1
        }
    }
    
    /// Error code.
    var errorCode: String? {
        switch self {
        case .serverError(_, let code, _): return code
        default: return nil
        }
    }
    
    /// Indicator whether an error type is `isPreconditionFulfilled`.
    var isPreconditionFulfilled: Bool {
        switch self {
        case .preconditionRequired: return false
        default: return true
        }
    }
}

// MARK: - Implementation of the `LocalizedError` protocol.
extension HttpError: LocalizedError {
    
    /// Error desctiption.
    public var errorDescription: String? {
        switch self {
        case .serverError(_, _, let message): return message
        case .preconditionRequired(let message): return message
        case .unauthorized: return "User is Unauthorized"
        case .notFound(let message): return message
        case .alreadyDone(let message): return message
        case .parserError(let message): return message
        case .generalError(let message): return message
        default: return "Unexpected error"
        }
    }
}

// MARK: - Helper `ApiResponse` properties.
extension ApiResponse {
    
    /// Error of type `HttpError`
    var error: HttpError {
        if statusCode == HTTPCodes.preconditionRequired {
            return .preconditionRequired(message: errorInfo?.message)
        } else if statusCode == HTTPCodes.alreadyDone {
            return .alreadyDone(message: errorInfo?.message)
        } else if statusCode == HTTPCodes.notFound {
            return .notFound(message: errorInfo?.message)
        }
        return .serverError(code: statusCode ?? 200, errorCode: errorInfo?.code, message: errorInfo?.message ?? message)
    }
}

// MARK: - Private `Data` helper methods.
private extension Data {
    func asApiError(code: Int) -> HttpError? {
        guard var response = try? JSONDecoder().decode(ApiResponse<EmptyResponse>.self, from: self) else {
            return nil
        }
        response.statusCode = code
        return response.error
    }
}
