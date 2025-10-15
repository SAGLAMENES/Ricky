//
//  NetworkClientProtocol.swift
//  RickyNetworkInterface
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation
import Combine

public protocol NetworkClientProtocol {
    func performRequest<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError>
}