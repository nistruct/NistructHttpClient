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
    func callApi<T: Decodable>(endpoint: HttpEndpoint, body: [String: AnyObject]? = nil) -> AnyPublisher<ApiResponse<T>, Error> {
        endpoint.printRequest(body: body)
        
        let start = CFAbsoluteTimeGetCurrent()
        
        return tokenProvider
            .fetchToken()
            .tryMap { token in
                try endpoint.urlRequest(baseURL: self.baseURL, body: body, authorizationHeader: token.value)
            }
            .flatMap { request in
                return self.session
                    .dataTaskPublisher(for: request)
                    .retry(3)
                    .processResponse()
            }
            .handleEvents(receiveCompletion: { _ in
                let diff = CFAbsoluteTimeGetCurrent() - start
                print("\(diff) sec")
            })
            .mapError {
                handleImportantErrors($0)
                return $0
            }
            .holdResponse(toBeAtLeast: 0.5)
    }
    
    func call<T: Decodable>(endpoint: HttpEndpoint, body: [String: AnyObject]? = nil) -> AnyPublisher<T, Error> {
        endpoint.printRequest(body: body)
        
        let start = CFAbsoluteTimeGetCurrent()
        
        return tokenProvider
            .fetchToken()
            .tryMap { token in
                try endpoint.urlRequest(baseURL: self.baseURL, body: body, authorizationHeader: token.value)
            }
            .flatMap { request in
                return self.session
                    .dataTaskPublisher(for: request)
                    .retry(3)
                    .processApiResponse(url: request.url)
            }
            .handleEvents(receiveCompletion: { _ in
                let diff = CFAbsoluteTimeGetCurrent() - start
                print("\(diff) sec")
            })
            .mapError {
                handleImportantErrors($0)
                return $0
            }
            .holdResponse(toBeAtLeast: 0.5)
    }
    
    func unauthorizedCall<T: Decodable>(endpoint: HttpEndpoint, body: [String: AnyObject]? = nil) -> AnyPublisher<T, Error> {
        endpoint.printRequest(body: body)
        
        let start = CFAbsoluteTimeGetCurrent()
        
        guard let request = try? endpoint.urlRequest(baseURL: self.baseURL, body: body) else {
            return Future<T, Error> { promise in
                promise(.failure(HttpError.invalidRequest))
            }.eraseToAnyPublisher()
        }
        
        return self.session
            .dataTaskPublisher(for: request)
            .retry(3)
            .processApiResponse(url: request.url)
            .handleEvents(receiveCompletion: { _ in
                let diff = CFAbsoluteTimeGetCurrent() - start
                print("\(diff) sec")
            })
            .mapError {
                handleImportantErrors($0)
                return $0
            }
            .holdResponse(toBeAtLeast: 0.5)
    }
}

private extension HttpClient {
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
    func processResponse<T: Decodable>() -> AnyPublisher<T, Error> {
        return tryMap {
            guard let statusCode = ($0.response as? HTTPURLResponse)?.statusCode else {
                throw HttpError.unexpectedResponse
            }
            
            if let error = HttpError.error(withCode: statusCode, data: $0.data) {
                Swift.print("Http Client: Error - \(error)")
                throw error
            }
            
            if $0.data.isEmpty, let data = "{}".data(using: .utf8) {
                return data
            }
            return $0.data
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func processApiResponse<T: Decodable>(url: URL? = nil) -> AnyPublisher<T, Error> {
        return tryMap {
            guard let statusCode = ($0.response as? HTTPURLResponse)?.statusCode else {
                throw HttpError.unexpectedResponse
            }
            
            if let error = HttpError.error(withCode: statusCode, data: $0.data) {
                Swift.print("Http Client: Error - \(error)")
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
                if HTTPCodes.success.contains($0.statusCode) {
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
            Swift.print("\n----")
            Swift.print(url?.absoluteString ?? "")
            Swift.print(json)
            Swift.print("----\n")
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
