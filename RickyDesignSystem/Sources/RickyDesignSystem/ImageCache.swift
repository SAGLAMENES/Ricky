//
//  ImageCache.swift
//  RickyDesignSystem
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// Thread-safe image cache using NSCache
public final class ImageCache: @unchecked Sendable {
    public static let shared = ImageCache()

    #if canImport(UIKit)
    private let cache = NSCache<NSURL, UIImage>()
    #endif

    private let diskCacheURL: URL
    private let fileManager = FileManager.default

    private init() {
        #if canImport(UIKit)
        // Configure NSCache
        cache.countLimit = 100 // Maximum 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit

        // Setup disk cache directory
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDirectory.appendingPathComponent("ImageCache")

        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)

        // Listen for memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        #else
        diskCacheURL = URL(fileURLWithPath: NSTemporaryDirectory())
        #endif
    }

    deinit {
        #if canImport(UIKit)
        NotificationCenter.default.removeObserver(self)
        #endif
    }

    // MARK: - Public Methods

    #if canImport(UIKit)
    /// Get image from cache (memory or disk)
    public func get(for url: URL) -> UIImage? {
        // Check memory cache first
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        // Check disk cache
        if let diskImage = loadFromDisk(for: url) {
            // Promote to memory cache
            cache.setObject(diskImage, forKey: url as NSURL)
            return diskImage
        }

        return nil
    }

    /// Set image in cache (memory and disk)
    public func set(_ image: UIImage, for url: URL) {
        // Store in memory
        cache.setObject(image, forKey: url as NSURL)

        // Store on disk asynchronously
        DispatchQueue.global(qos: .utility).async { [weak self] in
            self?.saveToDisk(image, for: url)
        }
    }

    /// Remove image from cache
    public func remove(for url: URL) {
        cache.removeObject(forKey: url as NSURL)

        let fileURL = diskFileURL(for: url)
        try? fileManager.removeItem(at: fileURL)
    }

    /// Clear all cached images
    public func clearAll() {
        cache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheURL)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
    #endif

    #if canImport(UIKit)
    /// Clear expired images (older than specified days)
    public func clearExpired(olderThanDays days: Int = 7) {
        let expirationDate = Date().addingTimeInterval(-TimeInterval(days * 24 * 60 * 60))

        guard let files = try? fileManager.contentsOfDirectory(
            at: diskCacheURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        ) else { return }

        for fileURL in files {
            guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                  let modificationDate = attributes[.modificationDate] as? Date,
                  modificationDate < expirationDate else {
                continue
            }

            try? fileManager.removeItem(at: fileURL)
        }
    }

    // MARK: - Private Methods

    private func diskFileURL(for url: URL) -> URL {
        let fileName = url.absoluteString
            .addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return diskCacheURL.appendingPathComponent(fileName)
    }

    private func saveToDisk(_ image: UIImage, for url: URL) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }

        let fileURL = diskFileURL(for: url)
        try? data.write(to: fileURL)
    }

    private func loadFromDisk(for url: URL) -> UIImage? {
        let fileURL = diskFileURL(for: url)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    @objc private func handleMemoryWarning() {
        cache.removeAllObjects()
    }
    #endif
}
