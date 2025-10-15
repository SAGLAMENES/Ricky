//
//  NetworkClient.swift
//  RickyNetwork
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation
import Combine
import RickyNetworkInterface

public final class NetworkClient: NetworkClientProtocol {
    private let urlSession: URLSession
    
    public init(configuration: URLSessionConfiguration = .default) {
        self.urlSession = URLSession(configuration: configuration)
    }

    public func performRequest<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        do {
            let request = try RequestBuilder.build(from: endpoint)
            
            return urlSession.dataTaskPublisher(for: request)
                .tryMap { data, response in
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw NetworkError.requestFailed(-1)
                    }
                    guard (200..<300).contains(httpResponse.statusCode) else {
                        throw NetworkError.requestFailed(httpResponse.statusCode)
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error in
                    if let networkError = error as? NetworkError {
                        return networkError
                    } else if error is DecodingError {
                        return .decodingFailed
                    } else {
                        return .unknown(error)
                    }
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
            
        } catch {
            return Fail(error: .invalidURL)
                .eraseToAnyPublisher()
        }
    }
}
