//
//  Factory.swift
//  RickyDI
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

public final class Factory<T> {
    private let builder: () -> T
    public init(_ builder: @escaping () -> T) {
        self.builder = builder
    }
    public func resolve() -> T {
        builder()
    }
}