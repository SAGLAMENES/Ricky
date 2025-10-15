//
//  RequestType.swift
//  RickyNetworkInterface
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

public enum RequestType {
    case plain
    case query(_ parameters: [String: Any])
    case body(_ data: Data)
}