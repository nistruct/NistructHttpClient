//
//  HttpError.swift
//
//  Created by Nikola Nikolic on 3/18/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation

public enum HttpError: Error {
    case invalidURL
    case unauthorized
    case invalidRequest
    case unexpectedResponse
    case preconditionRequired(message: String?)
    case notFound(message: String?)
    case alreadyDone(message: String?)
    case serverError(code: Int, message: String?)
    case upgradeRequired
}

typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

public extension HTTPCodes {
    static let success              = 200 ..< 300
    static let unauthorized         = 401
    static let preconditionRequired = 428
    static let notFound             = 404
    static let alreadyDone          = 410
    static let upgradeRequired      = 426
}

extension HttpError {
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
        
        guard let error = data.asApiError() else {
            return nil
        }
        
        return error
    }
}

extension HttpError {
    var code: Int {
        switch self {
        case .serverError(let code, _): return code
        case .preconditionRequired: return HTTPCodes.preconditionRequired
        case .alreadyDone: return HTTPCodes.alreadyDone
        case .notFound: return HTTPCodes.notFound
        case .unauthorized: return HTTPCodes.unauthorized
        default: return -1
        }
    }
    
    var isPreconditionFulfilled: Bool {
        switch self {
        case .preconditionRequired: return false
        default: return true
        }
    }
}

extension HttpError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .serverError(_, let message): return message
        case .preconditionRequired(let message): return message
        case .unauthorized: return "User is Unauthorized"
        case .notFound(let message): return message
        case .alreadyDone(let message): return message
        default: return "Unexpected error"
        }
    }
}

extension ApiResponse {
    var error: HttpError {
        if statusCode == HTTPCodes.preconditionRequired {
            return .preconditionRequired(message: errorInfo?.message)
        } else if statusCode == HTTPCodes.alreadyDone {
            return .alreadyDone(message: errorInfo?.message)
        } else if statusCode == HTTPCodes.notFound {
            return .notFound(message: errorInfo?.message)
        }
        return .serverError(code: statusCode, message: errorInfo?.message)
    }
}

private extension Data {
    func asApiError() -> HttpError? {
        guard let response = try? JSONDecoder().decode(ApiResponse<EmptyResponse>.self, from: self) else {
            return nil
        }
        return response.error
    }
}
