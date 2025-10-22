//
//  PersistenceError.swift
//  RickyPersistance
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

public enum PersistenceError: Error {
    case encodingFailed
    case decodingFailed
    case fileNotFound
    case unknown(Error)
}