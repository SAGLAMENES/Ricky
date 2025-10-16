//
//  LocationListView.swift
//  RickyApp
//
//  Created by Burak Arslan on 14.10.2025.
//

import SwiftUI
import RickyDesignSystem
import RickyDomain
import RickyRouter

struct LocationListView: View {
    @StateObject private var viewModel = LocationListViewModel()
    @EnvironmentObject private var router: RouterService

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.locations.isEmpty {
                ProgressView("Loading locations...")
            } else if let error = viewModel.errorMessage, viewModel.locations.isEmpty {
                ErrorView(message: error, retry: viewModel.refresh)
            } else if viewModel.locations.isEmpty {
                EmptyLocationView()
            } else {
                LocationList(viewModel: viewModel, router: router)
            }
        }
        .navigationTitle("Locations")
        .onAppear {
            if viewModel.locations.isEmpty {
                viewModel.fetchLocations()
            }
        }
    }
}

// MARK: - Location List

struct LocationList: View {
    @ObservedObject var viewModel: LocationListViewModel
    let router: RouterService

    var body: some View {
        List {
            ForEach(viewModel.locations, id: \.id) { location in
                LocationRow(location: location)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        router.navigate(to: .locationDetail(location))
                    }
                    .onAppear {
                        if location.id == viewModel.locations.last?.id {
                            viewModel.loadMore()
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

// MARK: - Location Row

struct LocationRow: View {
    let location: LocationEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(location.name)
                .font(.headline)

            HStack(spacing: 16) {
                Label(location.displayType, systemImage: "building.2")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let dimension = location.dimension {
                    Label(dimension, systemImage: "cube")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            if location.hasResidents {
                Label("\(location.residentCount) residents", systemImage: "person.3")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty View

struct EmptyLocationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 50))
                .foregroundColor(.gray)

            Text("No Locations Found")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Locations will appear here")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            LocationListView()
                .environmentObject(RouterService.shared)
        }
    } else {
        NavigationView {
            LocationListView()
                .environmentObject(RouterService.shared)
        }
    }
}
