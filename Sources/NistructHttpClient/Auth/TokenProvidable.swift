//
//  TokenProviderProtocol.swift
//
//  Created by Nikola Nikolic on 4/16/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation
import Combine

public protocol TokenProvidable {
    func save(_ token: Token) -> AnyPublisher<Void, Never>
    func fetchToken() -> AnyPublisher<Token, Error>
    func clearLocalToken()
    func clear() -> AnyPublisher<Void, Never>
    func fetchClientToken() -> AnyPublisher<Token, Error>
    func refreshToken() -> AnyPublisher<Void, Error>
}
