//
//  HttpClient.swift
//
//  Created by Nikola Nikolic on 3/18/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation
import Combine

public protocol HttpClient {
    var session: URLSession { get }
    var baseURL: String { get }
    var authenticator: Authenticatable { get }
    var tokenProvider: TokenProvidable { get }
}

public extension HttpClient {
    func callApi<T: Decodable>(endpoint: HttpEndpoint,
                               body: [String: AnyObject]? = nil) -> AnyPublisher<ApiResponse<T>, HttpError> {
        endpoint.printRequest(url: baseURL, body: body)
        
        let start = CFAbsoluteTimeGetCurrent()
        
        return tokenProvider
            .fetchToken()
            .tryMap { token in
                try endpoint.urlRequest(baseURL: baseURL,
                                        body: body,
                                        authorizationHeader: .bearer(token: token.value))
            }
            .flatMap { request in
                return self.session
                    .dataTaskPublisher(for: request)
                    .retry(3)
                    .processApiResponse()
            }
            .handleEvents(receiveCompletion: { _ in
                let diff = CFAbsoluteTimeGetCurrent() - start
                print("\(diff) sec")
            })
            .mapError {
                handleImportantErrors($0)
                return $0.httpError
            }
            .holdResponse(toBeAtLeast: 0.5)
    }
    
    func call<T: Decodable>(endpoint: HttpEndpoint, body: [String: AnyObject]? = nil, authType: AuthorizationType = .access) -> AnyPublisher<T, HttpError> {
        endpoint.printRequest(url: baseURL, body: body)
        
        return createRequest(endpoint: endpoint, body: body, authType: authType)
            .flatMap(performRequest)
            .eraseToAnyPublisher()
    }
}

private extension HttpClient {
    func createRequest(endpoint: HttpEndpoint, body: [String: AnyObject]? = nil, authType: AuthorizationType = .access) -> AnyPublisher<URLRequest, HttpError> {
        switch authType {
        case .no:
            return createGeneralRequest(endpoint: endpoint, body: body)
        case .basic(let token):
            return createBasicRequest(endpoint: endpoint, body: body, token: token)
        case .client:
            return createClientRequest(endpoint: endpoint, body: body)
        case .access:
            return createAccessRequest(endpoint: endpoint, body: body)
        }
    }
    
    func createGeneralRequest(endpoint: HttpEndpoint, body: [String: AnyObject]? = nil) -> AnyPublisher<URLRequest, HttpError> {
        guard let request = try? endpoint.urlRequest(baseURL: baseURL, body: body) else {
            return Fail(error: HttpError.invalidRequest).eraseToAnyPublisher()
        }
        return Just(request)
            .setFailureType(to: HttpError.self)
            .eraseToAnyPublisher()
    }
    
    func createBasicRequest(endpoint: HttpEndpoint, body: [String: AnyObject]? = nil, token: String) -> AnyPublisher<URLRequest, HttpError> {
        guard let request = try? endpoint.urlRequest(baseURL: baseURL,
                                                     body: body,
                                                     authorizationHeader: .basic(token: token)) else {
            return Fail(error: HttpError.invalidRequest).eraseToAnyPublisher()
        }
        return Just(request)
            .setFailureType(to: HttpError.self)
            .eraseToAnyPublisher()
    }
    
    func createClientRequest(endpoint: HttpEndpoint, body: [String: AnyObject]? = nil) -> AnyPublisher<URLRequest, HttpError> {
        tokenProvider
            .fetchClientToken()
            .tryMap { token in
                try endpoint.urlRequest(baseURL: baseURL, body: body, authorizationHeader: .bearer(token: token.value))
            }
            .mapError { _ in HttpError.invalidRequest }
            .eraseToAnyPublisher()
    }
    
    func createAccessRequest(endpoint: HttpEndpoint, body: [String: AnyObject]? = nil) -> AnyPublisher<URLRequest, HttpError> {
        tokenProvider
            .fetchToken()
            .tryMap { token in
                try endpoint.urlRequest(baseURL: baseURL, body: body, authorizationHeader: .bearer(token: token.value))
            }
            .mapError { _ in HttpError.invalidRequest }
            .eraseToAnyPublisher()
    }
    
    func performRequest<T: Decodable>(request: URLRequest) -> AnyPublisher<T, HttpError> {
        let start = CFAbsoluteTimeGetCurrent()
        
        return session
            .dataTaskPublisher(for: request)
            .retry(3)
            .processResponse(url: request.url)
            .handleEvents(receiveCompletion: { _ in
                let diff = CFAbsoluteTimeGetCurrent() - start
                print("\(diff) sec")
            })
            .mapError {
                handleImportantErrors($0)
                return $0.httpError
            }
            .holdResponse(toBeAtLeast: 0.5)
    }
    
    func handleImportantErrors(_ error: Error) {
        switch error {
        case HttpError.unauthorized:
            print("**** UNAUTHORIZED -> SIGN OUT")
            _ = self.authenticator.signOut()
            break
        case HttpError.upgradeRequired:
            print("**** UPDATE NEEDED")
            NotificationCenter.default.post(name: .UpdateNeeded, object: nil)
            break
        default:
            break
        }
    }
}

private extension Publisher where Output == URLSession.DataTaskPublisher.Output {
    func processResponse<T: Decodable>(url: URL? = nil) -> AnyPublisher<T, Error> {
        tryMap {
            guard let statusCode = ($0.response as? HTTPURLResponse)?.statusCode else {
                throw HttpError.unexpectedResponse
            }
            
            if let error = HttpError.error(withCode: statusCode, data: $0.data) {
                Swift.print("Http Client: Error - \(error), status code: \(statusCode)")
                throw error
            }
            
            if $0.data.isEmpty, let data = "{}".data(using: .utf8) {
                return data
            }
            return $0.data
        }
        .printResponse(url: url)
        .decode(type: T.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func processApiResponse<T: Decodable>(url: URL? = nil) -> AnyPublisher<T, Error> {
        tryMap {
            guard let statusCode = ($0.response as? HTTPURLResponse)?.statusCode else {
                throw HttpError.unexpectedResponse
            }
            
            if let error = HttpError.error(withCode: statusCode, data: $0.data) {
                Swift.print("Http Client: Error - \(error), status code: \(statusCode)")
                throw error
            }
            
            if $0.data.isEmpty, let data = "{}".data(using: .utf8) {
                return data
            }
            return $0.data
        }
        .printResponse(url: url)
        .decode(type: ApiResponse<T>.self, decoder: JSONDecoder())
        .tryMap {
            guard let data = $0.data else {
                if HTTPCodes.success.contains($0.statusCode ?? 200) {
                    return EmptyResponse() as! T
                }
                throw $0.error
            }
            return data
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func printResponse(url: URL? = nil) -> AnyPublisher<Data, Failure> {
        handleEvents(receiveOutput: { data in
            guard let json = data.toJson() else {
                return
            }
            Swift.print("\n----API RESPONSE----")
            Swift.print(url?.absoluteString ?? "")
            Swift.print(json)
            Swift.print("----API RESPONSE----\n")
        })
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func holdResponse(toBeAtLeast interval: TimeInterval) -> AnyPublisher<Output, Failure> {
        let timer = Just(())
            .delay(for: .seconds(interval), scheduler: RunLoop.main)
            .setFailureType(to: Failure.self)
        
        return zip(timer)
            .map { $0.0 }
            .eraseToAnyPublisher()
    }
}

extension Error {
    var httpError: HttpError {
        guard let httpError = self as? HttpError else {
            return .generalError(message: localizedDescription)
        }
        return httpError
    }
}
