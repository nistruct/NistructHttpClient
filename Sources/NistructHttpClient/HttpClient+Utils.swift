//
//  HttpClient+Utils.swift
//  
//
//  Created by Nikola Nikolic on 5.10.22..
//

import Combine

struct ArrayResponse<T>: Decodable where T: Decodable {
    let content: T
}

extension HttpClient {
    func fetchArray<T>(endpoint: HttpEndpoint,
                       body: [String: AnyObject]? = nil,
                       authType: AuthorizationType = .access) -> AnyPublisher<ArrayResponse<[T]>, HttpError> {
        call(endpoint: endpoint, body: body, authType: authType)
            .eraseToAnyPublisher()
    }
}
