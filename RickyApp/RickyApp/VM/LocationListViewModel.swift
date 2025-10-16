//
//  LocationListViewModel.swift
//  RickyApp
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import Combine
import RickyDI
import RickyDomain

@MainActor
final class LocationListViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var locations: [LocationEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var currentPage: Int = 1

    // MARK: - Dependencies

    private let fetchLocationsUseCase: FetchLocationsUseCase

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var canLoadMore = true

    // MARK: - Initialization

    init(fetchLocationsUseCase: FetchLocationsUseCase = ServiceContainer.shared.fetchLocationsUseCase.resolve()) {
        self.fetchLocationsUseCase = fetchLocationsUseCase
    }

    // MARK: - Public Methods

    func fetchLocations(refresh: Bool = false) {
        guard !isLoading else { return }

        if refresh {
            currentPage = 1
            locations = []
            canLoadMore = true
        }

        isLoading = true
        errorMessage = nil

        let parameters = FetchLocationsParameters(page: currentPage, refresh: refresh)

        fetchLocationsUseCase
            .execute(parameters: parameters)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.errorDescription
                    self?.canLoadMore = false
                }
            } receiveValue: { [weak self] entities in
                guard let self = self else { return }

                if refresh {
                    self.locations = entities
                } else {
                    self.locations.append(contentsOf: entities)
                }

                if entities.isEmpty {
                    self.canLoadMore = false
                }
            }
            .store(in: &cancellables)
    }

    func loadMore() {
        guard canLoadMore, !isLoading else { return }
        currentPage += 1
        fetchLocations()
    }

    func refresh() {
        fetchLocations(refresh: true)
    }
}
