//
//  CharacterDetailView.swift
//  RickyApp
//
//  Created by Burak Arslan on 14.10.2025.
//

import SwiftUI
import Combine
import RickyDesignSystem
import RickyDomain
import RickyRouter
import RickyDI

struct CharacterDetailView: View {
    let character: CharacterEntity
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: RouterService
    @State private var isFavorite: Bool
    @State private var isTogglingFavorite: Bool = false
    
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private var cancellables = Set<AnyCancellable>()

    init(
        character: CharacterEntity,
        toggleFavoriteUseCase: ToggleFavoriteUseCase = ServiceContainer.shared.toggleFavoriteUseCase.resolve()
    ) {
        self.character = character
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        _isFavorite = State(initialValue: character.isFavorite)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                ZStack(alignment: .topTrailing) {
                    CachedAsyncImage(url: character.imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ShimmerPlaceholder()
                    }
                    .frame(height: 400)
                    .clipped()
          
                }

                // Character Info
                VStack(spacing: 24) {
                    // Name and Status
                    VStack(spacing: 12) {
                        Text(character.name)
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)

                        HStack(spacing: 8) {
                            Circle()
                                .fill(statusColor(for: character.status))
                                .frame(width: 12, height: 12)

                            Text(character.status.rawValue)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 24)

                    // Info Grid
                    VStack(spacing: 16) {
                        InfoCard(
                            icon: "person.fill",
                            title: "Species",
                            value: character.species
                        )

                        InfoCard(
                            icon: "figure.dress.line.vertical.figure",
                            title: "Gender",
                            value: character.gender.rawValue
                        )

                        if !character.type.isEmpty {
                            InfoCard(
                                icon: "tag.fill",
                                title: "Type",
                                value: character.type
                            )
                        }

                        InfoCard(
                            icon: "globe",
                            title: "Origin",
                            value: character.origin.displayName
                        )

                        InfoCard(
                            icon: "location.fill",
                            title: "Last Known Location",
                            value: character.location.displayName
                        )

                        InfoCard(
                            icon: "film.fill",
                            title: "Episodes",
                            value: "\(character.episodeCount) episodes"
                        )
                    }
                    .padding(.horizontal)

                    // Additional Info
                    if character.isFromEarth {
                        HStack {
                            Image(systemName: "globe.americas.fill")
                                .foregroundColor(.blue)
                            Text("Character is from Earth")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .padding(.horizontal)
                    }

                    // Explore Locations Button
                    Button(action: {
                        router.navigate(to: .locationList)
                    }) {
                        HStack {
                            Image(systemName: "map")
                                .font(.title3)
                            Text("Explore All Locations")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .white)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: shareCharacter) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func statusColor(for status: CharacterStatus) -> Color {
        switch status {
        case .alive: return .green
        case .dead: return .red
        case .unknown: return .gray
        }
    }

    private func toggleFavorite() {
        guard !isTogglingFavorite else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isFavorite.toggle()
        }
        
        let oldFavoriteState = !isFavorite
        isTogglingFavorite = true
        
        let parameters = ToggleFavoriteParameters(characterId: character.id)
        var cancellable: AnyCancellable?
        
        cancellable = toggleFavoriteUseCase
            .execute(parameters: parameters)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                isTogglingFavorite = false
                
                if case let .failure(_) = completion {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isFavorite = oldFavoriteState
                    }
                }
                cancellable?.cancel()
            } receiveValue: { newFavoriteStatus in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isFavorite = newFavoriteStatus
                }
            }
    }

    private func shareCharacter() {
        guard let url = character.profileURL else { return }

        let activityVC = UIActivityViewController(
            activityItems: ["\(character.name) from Rick & Morty", url],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Info Card

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

// MARK: - Preview

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            CharacterDetailView(
                character: CharacterEntity(
                    id: 1,
                    name: "Rick Sanchez",
                    status: .alive,
                    species: "Human",
                    type: "",
                    gender: .male,
                    origin: LocationEntity(name: "Earth (C-137)", url: nil),
                    location: LocationEntity(name: "Citadel of Ricks", url: nil),
                    imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
                    episodeURLs: [],
                    profileURL: URL(string: "https://rickandmortyapi.com/api/character/1"),
                    createdDate: Date(),
                    isFavorite: false
                )
            )
            .environmentObject(RouterService.shared)
        }
    } else {
        NavigationView {
            CharacterDetailView(
                character: CharacterEntity(
                    id: 1,
                    name: "Rick Sanchez",
                    status: .alive,
                    species: "Human",
                    type: "",
                    gender: .male,
                    origin: LocationEntity(name: "Earth (C-137)", url: nil),
                    location: LocationEntity(name: "Citadel of Ricks", url: nil),
                    imageURL: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"),
                    episodeURLs: [],
                    profileURL: URL(string: "https://rickandmortyapi.com/api/character/1"),
                    createdDate: Date(),
                    isFavorite: false
                )
            )
            .environmentObject(RouterService.shared)
        }
    }
}
