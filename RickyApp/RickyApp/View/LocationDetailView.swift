//
//  LocationDetailView.swift
//  RickyApp
//
//  Created by Burak Arslan on 14.10.2025.
//

import SwiftUI
import RickyDesignSystem
import RickyDomain

struct LocationDetailView: View {
    let location: LocationEntity

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero Section
                LocationHeroSection(location: location)

                // Info Cards
                VStack(spacing: 12) {
                    InfoCard(
                        icon: "building.2",
                        title: "Type",
                        value: location.displayType
                    )

                    if let dimension = location.dimension {
                        InfoCard(
                            icon: "cube",
                            title: "Dimension",
                            value: dimension
                        )
                    }

                    if location.hasResidents {
                        InfoCard(
                            icon: "person.3",
                            title: "Residents",
                            value: "\(location.residentCount) residents"
                        )
                    }

                    InfoCard(
                        icon: "calendar",
                        title: "Created",
                        value: location.createdDate?.formatted() ?? "Unknown"
                    )
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Hero Section

struct LocationHeroSection: View {
    let location: LocationEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Location Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 200)

                VStack(spacing: 12) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    Text(location.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}

// Note: InfoCard is defined in CharacterDetailView.swift

// MARK: - Preview

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            LocationDetailView(location: LocationEntity(
                id: 1,
                name: "Earth (C-137)",
                url: nil,
                type: "Planet",
                dimension: "Dimension C-137",
                residentURLs: [],
                createdDate: nil
            ))
        }
    } else {
        NavigationView {
            LocationDetailView(location: LocationEntity(
                id: 1,
                name: "Earth (C-137)",
                url: nil,
                type: "Planet",
                dimension: "Dimension C-137",
                residentURLs: [],
                createdDate: nil
            ))
        }
    }
}
