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
    func fetchArray<T>(endpoint: HttpEndpoint) -> AnyPublisher<ArrayResponse<[T]>, HttpError> {
        call(endpoint: endpoint)
            .eraseToAnyPublisher()
    }
}
