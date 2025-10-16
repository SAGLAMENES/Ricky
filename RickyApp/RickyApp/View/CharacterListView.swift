//
//  CharacterListView.swift
//  RickyApp
//
//  Created by Burak Arslan on 14.10.2025.
//


import SwiftUI
import RickyDesignSystem
import RickyDomain
import RickyRouter

struct CharacterListView: View {
    @StateObject private var viewModel = CharacterListViewModel()
    @StateObject private var router = RouterService.shared

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(path: $router.path) {
                contentView
                    .navigationTitle("Rick & Morty")
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(for: route)
                    }
                    .searchable(text: $viewModel.searchQuery, prompt: "Search characters")
                    .onAppear {
                        if viewModel.characters.isEmpty {
                            viewModel.fetchCharacters()
                        }
                    }
            }
            .environmentObject(router)
        } else {
            NavigationView {
                contentView
                    .navigationTitle("Rick & Morty")
                    .searchable(text: $viewModel.searchQuery, prompt: "Search characters")
                    .onAppear {
                        if viewModel.characters.isEmpty {
                            viewModel.fetchCharacters()
                        }
                    }
            }
            .environmentObject(router)
        }
    }

    @ViewBuilder
    private func routeDestination(for route: Route) -> some View {
        switch route {
        case .characterList:
            EmptyView() // Root, never pushed

        case .characterDetail(let character):
            CharacterDetailView(character: character)

        case .locationList:
            LocationListView()

        case .locationDetail(let location):
            LocationDetailView(location: location)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        ZStack {
            if viewModel.isLoading && viewModel.characters.isEmpty {
                CharacterListSkeletonView()
            } else if let error = viewModel.errorMessage, viewModel.characters.isEmpty {
                ErrorView(message: error, retry: viewModel.refresh)
            } else if viewModel.characters.isEmpty {
                EmptyStateView()
            } else {
                CharacterList(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Character List

struct CharacterList: View {
    @ObservedObject var viewModel: CharacterListViewModel
    @EnvironmentObject private var router: RouterService

    var body: some View {
        List {
            ForEach(viewModel.characters, id: \.id) { character in
                if #available(iOS 16.0, *) {
                    NavigationLink(value: Route.characterDetail(character)) {
                        CharacterRow(character: character) {
                            viewModel.toggleFavorite(characterId: character.id)
                        }
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if character.id == viewModel.characters.last?.id {
                            viewModel.loadMore()
                        }
                    }
                } else {
                    NavigationLink(destination: CharacterDetailView(character: character)) {
                        CharacterRow(character: character) {
                            viewModel.toggleFavorite(characterId: character.id)
                        }
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if character.id == viewModel.characters.last?.id {
                            viewModel.loadMore()
                        }
                    }
                }
            }

            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.refresh()
        }
    }
}

// MARK: - Character Row

struct CharacterRow: View {
    let character: CharacterEntity
    let onFavoriteTap: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Character Image
            CachedAsyncImage(url: character.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ShimmerPlaceholder()
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())

            // Character Info
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.headline)

                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor(for: character.status))
                        .frame(width: 8, height: 8)

                    Text(character.displayStatus)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(character.location.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Favorite Button
            Button(action: onFavoriteTap) {
                Image(systemName: character.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(character.isFavorite ? .red : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }

    private func statusColor(for status: CharacterStatus) -> Color {
        switch status {
        case .alive: return .green
        case .dead: return .red
        case .unknown: return .gray
        }
    }
}

// MARK: - Error View

struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Oops!")
                .font(.title)
                .fontWeight(.bold)

            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Try Again", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No Characters Found")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Try adjusting your search")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Previews

#Preview {
    CharacterListView()
}
