//
//  ResponseDecoder.swift
//  RickyNetwork
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation
import RickyNetworkInterface

public struct ResponseDecoder {
    public static func decode<T: Decodable>(_ data: Data) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
