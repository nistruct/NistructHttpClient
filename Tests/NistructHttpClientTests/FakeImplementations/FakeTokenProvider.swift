//
//  FakeTokenProvider.swift
//
//  Created by Nikola Nikolic on 29.4.21..
//  Copyright © 2021 Nistruct. All rights reserved.
//

import Foundation
import Combine
@testable import NistructHttpClient

class FakeTokenProvider: TokenProvidable {
    func save(_ token: Token) -> AnyPublisher<Void, Never> {
        //TODO: Missing implementation
        Empty().eraseToAnyPublisher()
    }
    
    func fetchToken() -> AnyPublisher<Token, Error> {
        //TODO: Missing implementation
        Empty().eraseToAnyPublisher()
    }
    
    func clearLocalToken() {
        //TODO: Missing implementation
    }
    
    func clear() -> AnyPublisher<Void, Never> {
        //TODO: Missing implementation
        Empty().eraseToAnyPublisher()
    }
    
    func fetchClientToken() -> AnyPublisher<Token, Error> {
        //TODO: Missing implementation
        Empty().eraseToAnyPublisher()
    }
    
    func refreshToken() -> AnyPublisher<Token, Error> {
        //TODO: Missing implementation
        Empty().eraseToAnyPublisher()
    }
}
