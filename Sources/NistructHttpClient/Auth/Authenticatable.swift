//
//  Authenticatable.swift
//
//  Created by Nikola Nikolic on 3/24/20.
//  Copyright © 2020 Nistruct. All rights reserved.
//

import Foundation
import Combine

public protocol Authenticatable {
    func signOut() -> AnyPublisher<EmptyResponse, HttpError>
}
