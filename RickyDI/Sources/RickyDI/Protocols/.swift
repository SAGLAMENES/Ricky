//
//  DIContainerProtocol.swift
//  RickyDI
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

public protocol DIContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping () -> T, scope: LifecycleScope)
    func register<T>(_ type: T.Type, instance: T, scope: LifecycleScope)
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T>(_ type: T.Type) -> T?
    func isRegistered<T>(_ type: T.Type) -> Bool
    func unregister<T>(_ type: T.Type)
    func clear()
}

public protocol Injectable {
    // Marker protocol for types that can be injected
}

public protocol DIResolver {
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T>(_ type: T.Type) -> T?
}

// MARK: - Registration builders
public struct DIRegistration<T> {
    let factory: () -> T
    let scope: LifecycleScope
    let identifier: String
    
    init(factory: @escaping () -> T, scope: LifecycleScope, identifier: String = String(describing: T.self)) {
        self.factory = factory
        self.scope = scope
        self.identifier = identifier
    }
}