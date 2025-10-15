//
//  DiskCache.swift
//  RickyPersistance
//
//  Created by Burak Arslan on 14.10.2025.
//


import Foundation

public final class DiskCache<Value: Codable> {
    private let directory: URL
    private let fileManager = FileManager.default
    
    public init(folderName: String = "DiskCache") {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        directory = urls[0].appendingPathComponent(folderName)
        
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }
    
    public func save(_ value: Value, as fileName: String) throws {
        let fileURL = directory.appendingPathComponent(fileName)
        let data = try JSONEncoder().encode(value)
        try data.write(to: fileURL)
    }
    
    public func load(from fileName: String) throws -> Value {
        let fileURL = directory.appendingPathComponent(fileName)
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(Value.self, from: data)
    }
    
    public func delete(_ fileName: String) throws {
        let fileURL = directory.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}