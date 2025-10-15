//
//  Injectable.swift
//  RickyDI
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

public protocol Injectable {}

public extension Injectable {
    var di: ServiceContainer { ServiceContainer.shared }
}