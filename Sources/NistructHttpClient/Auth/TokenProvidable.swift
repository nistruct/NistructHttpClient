//
//  TokenProviderProtocol.swift
//
//  Created by Nikola Nikolic on 4/16/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation
import Combine

protocol TokenProvidable {
    func save(_ token: Token) -> AnyPublisher<Void, Never>
    func fetchToken() -> AnyPublisher<Token, Error>
    func clearLocalToken()
    func clear() -> AnyPublisher<Void, Never>
}