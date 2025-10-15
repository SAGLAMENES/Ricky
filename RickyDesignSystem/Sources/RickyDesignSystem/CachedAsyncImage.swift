//
//  CachedAsyncImage.swift
//  RickyDesignSystem
//
//  Created by Burak Arslan on 14.10.2025.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Cached version of AsyncImage with better performance
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    #if canImport(UIKit)
    @State private var loadedImage: UIImage?
    #else
    @State private var loadedImage: NSImage?
    #endif

    @State private var isLoading = false
    @State private var hasFailed = false

    public init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            if let loadedImage = loadedImage {
                #if canImport(UIKit)
                content(Image(uiImage: loadedImage))
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
                #else
                content(Image(nsImage: loadedImage))
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
                #endif
            } else if hasFailed {
                Image(systemName: "photo.fill")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }

    @MainActor
    private func loadImage() async {
        guard let url = url, loadedImage == nil else { return }

        isLoading = true
        hasFailed = false

        #if canImport(UIKit)
        // Check cache first
        if let cached = ImageCache.shared.get(for: url) {
            loadedImage = cached
            isLoading = false
            return
        }

        // Download image
        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            guard let uiImage = UIImage(data: data) else {
                hasFailed = true
                isLoading = false
                return
            }

            // Cache the image
            ImageCache.shared.set(uiImage, for: url)

            // Update UI
            withAnimation {
                loadedImage = uiImage
            }
            isLoading = false
        } catch {
            hasFailed = true
            isLoading = false
        }
        #else
        // macOS fallback - no caching
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let nsImage = NSImage(data: data) else {
                hasFailed = true
                isLoading = false
                return
            }
            withAnimation {
                loadedImage = nsImage
            }
            isLoading = false
        } catch {
            hasFailed = true
            isLoading = false
        }
        #endif
    }
}

// MARK: - Convenience Initializer

public extension CachedAsyncImage where Content == Image, Placeholder == Color {
    init(url: URL?) {
        self.init(
            url: url,
            content: { image in
                image
                    .resizable()
            },
            placeholder: {
                Color.gray.opacity(0.3)
            }
        )
    }
}
