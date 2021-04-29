//
//  FakeAuthenticator.swift
//
//  Created by Nikola Nikolic on 29.4.21..
//  Copyright © 2021 Nistruct. All rights reserved.
//

import Foundation
import Combine
@testable import NistructHttpClient

class FakeAuthenticator: Authenticatable {
    var error: Error?
    
    func signOut() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            if let error = self.error {
                promise(.failure(error))
            } else {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}
