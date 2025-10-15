//
//  UseCaseProtocol.swift
//  RickyDomain
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Combine

// Base protocol for all use cases
public protocol UseCaseProtocol {
    associatedtype Parameters
    associatedtype ReturnType
    associatedtype ErrorType: Error
    
    func execute(parameters: Parameters) -> AnyPublisher<ReturnType, ErrorType>
}

// Use case without parameters
public protocol NoParametersUseCaseProtocol {
    associatedtype ReturnType
    associatedtype ErrorType: Error
    
    func execute() -> AnyPublisher<ReturnType, ErrorType>
}

// Synchronous use case
public protocol SyncUseCaseProtocol {
    associatedtype Parameters
    associatedtype ReturnType
    associatedtype ErrorType: Error
    
    func execute(parameters: Parameters) throws -> ReturnType
}

// Use case with completion handler (for compatibility with older code)
public protocol CompletionUseCaseProtocol {
    associatedtype Parameters
    associatedtype ReturnType
    associatedtype ErrorType: Error
    
    func execute(parameters: Parameters, completion: @escaping (Result<ReturnType, ErrorType>) -> Void)
}