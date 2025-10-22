//
//  FavoritesView.swift
//  RickyApp
//
//  Created by Enes on 22.10.2025.
//

import SwiftUI
import RickyDesignSystem
import RickyDomain
import RickyRouter

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @EnvironmentObject private var router: RouterService
    @State private var showDeleteAllAlert = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(path: $router.path) {
                contentView
                    .navigationTitle("Favorites")
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(for: route)
                    }
                    .searchable(text: $viewModel.searchQuery, prompt: "Search favorites")
                   /* .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if !viewModel.favoriteCharacters.isEmpty {
                                Menu {
                                    Button(role: .destructive) {
                                        showDeleteAllAlert = true
                                    } label: {
                                        Label("Delete All", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                }
                            }
                        }
                    }
                    .alert("Delete All Favorites", isPresented: $showDeleteAllAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete All", role: .destructive) {
                            viewModel.deleteAllFavorites()
                        }
                    } message: {
                        Text("Are you sure you want to remove all favorite characters? This action cannot be undone.")
                    }*/
            }
        } else {
            NavigationView {
                contentView
                    .navigationTitle("Favorites")
                    .searchable(text: $viewModel.searchQuery, prompt: "Search favorites")
                  /*  .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if !viewModel.favoriteCharacters.isEmpty {
                                Menu {
                                    Button(role: .destructive) {
                                        showDeleteAllAlert = true
                                    } label: {
                                        Label("Delete All", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                }
                            }
                        }
                    }
                    .alert("Delete All Favorites", isPresented: $showDeleteAllAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Delete All", role: .destructive) {
                            viewModel.deleteAllFavorites()
                        }
                    } message: {
                        Text("Are you sure you want to remove all favorite characters? This action cannot be undone.")
                    }*/
            }
        }
    }
    
    @ViewBuilder
    private func routeDestination(for route: Route) -> some View {
        switch route {
        case .characterDetail(let character):
            CharacterDetailView(character: character)
        case .locationDetail(let location):
            LocationDetailView(location: location)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading favorites...")
            } else if let error = viewModel.errorMessage {
                FavoritesErrorView(message: error, retry: viewModel.refresh)
            } else if viewModel.displayedCharacters.isEmpty {
                emptyStateView
            } else {
                favoritesList
            }
        }
    }
    
    @ViewBuilder
    private var favoritesList: some View {
        List {
            ForEach(viewModel.displayedCharacters) { character in
                if #available(iOS 16.0, *) {
                    NavigationLink(value: Route.characterDetail(character)) {
                        FavoriteCharacterRow(character: character) {
                            viewModel.removeFavorite(characterId: character.id)
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    NavigationLink(destination: CharacterDetailView(character: character)) {
                        FavoriteCharacterRow(character: character) {
                            viewModel.removeFavorite(characterId: character.id)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.refresh()
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Characters you favorite will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}


struct FavoriteCharacterRow: View {
    let character: CharacterEntity
    let onRemoveTap: () -> Void
    
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
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor(for: character.status))
                        .frame(width: 8, height: 8)
                    
                    Text(character.displayStatus)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(character.location.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Remove Button
            Button(action: onRemoveTap) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
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


private struct FavoritesErrorView: View {
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

// MARK: - Previews

#Preview {
    FavoritesView()
        .environmentObject(RouterService.shared)
}

