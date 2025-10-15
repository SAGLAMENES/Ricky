//
//  ShimmerPlaceholder.swift
//  RickyDesignSystem
//
//  Created by Burak Arslan on 14.10.2025.
//

import SwiftUI

/// Animated shimmer effect for loading states
public struct ShimmerPlaceholder: View {
    @State private var isAnimating = false

    public init() {}

    public var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.1),
                        Color.gray.opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .mask {
                Rectangle()
                    .offset(x: isAnimating ? 400 : -400)
            }
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

/// Character row skeleton for loading state
public struct CharacterRowSkeleton: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 16) {
            // Avatar skeleton
            ShimmerPlaceholder()
                .frame(width: 60, height: 60)
                .clipShape(Circle())

            // Text skeletons
            VStack(alignment: .leading, spacing: 8) {
                ShimmerPlaceholder()
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)

                ShimmerPlaceholder()
                    .frame(height: 14)
                    .frame(width: 120)

                ShimmerPlaceholder()
                    .frame(height: 12)
                    .frame(width: 80)
            }

            Spacer()

            // Favorite button skeleton
            ShimmerPlaceholder()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
        }
        .padding(.vertical, 8)
    }
}

/// Character list skeleton view
public struct CharacterListSkeletonView: View {
    public init() {}

    public var body: some View {
        List {
            ForEach(0..<10, id: \.self) { _ in
                CharacterRowSkeleton()
            }
        }
        .listStyle(.plain)
        .disabled(true)
    }
}

// MARK: - Preview

#Preview("Shimmer Placeholder") {
    VStack(spacing: 20) {
        ShimmerPlaceholder()
            .frame(height: 100)
            .cornerRadius(12)

        CharacterRowSkeleton()

        CharacterListSkeletonView()
    }
    .padding()
}
