//
//  ResultsTests.swift
//  ResultsTests
//
//  Created by Marek Hajdučák on 14/09/2023.
//

import XCTest
import ComposableArchitecture

@testable import Livesport

@MainActor
final class ResultsTests: XCTestCase {

    func test_searchSuccess() async {
        let store = TestStore(initialState: ResultsFeature.State()) {
            ResultsFeature()
        } withDependencies: {
            $0.searchData.fetch = { search, sportIds, typeIds in
                [.dummy]
            }
            $0.imageDownloader.fetch = { path in
                return UIImage(systemName: "photo.on.rectangle")?.pngData()
            }
        }

        await store.send(.textChange("djokovic")) {
            $0.search = "djokovic"
        }

        await store.send(.searchButtonTapped) {
            $0.isLoading = true
            $0.isSearchValid = true
        }
        
        await store.receive(.searchResponse(.success([SearchResult.dummy])))

        await store.receive(.imageResponseByResult([SearchResult.dummy: UIImage(systemName: "photo.on.rectangle")?.pngData()])) {
            $0.isLoading = false
            $0.searchedData = [SearchResult.dummy].compactMap({ SearchResultViewModel(result: $0, imageData: UIImage(systemName: "photo.on.rectangle")?.pngData()) })
            $0.searchedModels = [SearchResult.dummy]
        }
    }

    func test_searchEmpty() async {
        let store = TestStore(initialState: ResultsFeature.State()) {
            ResultsFeature()
        } withDependencies: {
            $0.searchData.fetch = { search, sportIds, typeIds in
                []
            }
        }

        await store.send(.textChange("empty")) {
            $0.search = "empty"
        }

        await store.send(.searchButtonTapped) {
            $0.isLoading = true
            $0.isSearchValid = true
        }

        await store.receive(.searchResponse(.success([]))) {
            $0.emptyState = .emptySearch
            $0.isLoading = false
            $0.searchedData = []
        }
        
    }
    
    func test_searchIncorectInput() async {
        let store = TestStore(initialState: ResultsFeature.State()) {
            ResultsFeature()
        }
        
        await store.send(.textChange("d")) {
            $0.search = "d"
        }

        await store.send(.searchButtonTapped) {
            $0.isSearchValid = false
        }
    }

    func test_searchError() async {
        let store = TestStore(initialState: ResultsFeature.State()) {
            ResultsFeature()
        } withDependencies: {
            $0.searchData.fetch = { search, sportIds, typeIds in
                throw URLError(URLError.Code(rawValue: 400), userInfo: ["101" : "One or more values are missing, see array of errors for details."])
            }
        }

        await store.send(.textChange("dddddddddd")) {
            $0.search = "dddddddddd"
        }
        
        await store.send(.searchButtonTapped) {
            $0.isSearchValid = true
            $0.isLoading = true
        }

        await store.receive(.searchResponse(.failure(NSError(domain: "NSURLErrorDomain", code: 400, userInfo: ["101": "One or more values are missing, see array of errors for details."])))) {
            $0.emptyState = .errorSearch("The operation couldn’t be completed. (NSURLErrorDomain error 400.)")
            $0.isLoading = false
            $0.searchedData = []
            $0.destination = .alert(
                AlertState {
                    TextState("Vyskytla sa chyba: \("The operation couldn’t be completed. (NSURLErrorDomain error 400.)")")
                } actions: {
                    ButtonState(role: .destructive, action: .retrySearch) {
                        TextState("Znova")
                    }
                }
            )
        }
    }
    
    func test_competitionFilter() async {
        let store = TestStore(initialState: ResultsFeature.State()) {
            ResultsFeature()
        }
        
        await store.send(.typeFilterTagSelected(.participants)) {
            $0.selectedCompetitionFilter = .participants
            $0.competitionFilters.forEach { $0.isSelected = false }
            $0.competitionFilters.first { $0.id == CompetitionType.participants.rawValue }?.isSelected = true
        }
    }
    
    
    func test_sportFilter() async {
        let store = TestStore(initialState: ResultsFeature.State()) {
            ResultsFeature()
        }
        
        await store.send(.sportFilterTagSelected(.baseball)) {
            $0.selectedSportFilter = .baseball
            $0.sportFilters.forEach { $0.isSelected = false }
            $0.sportFilters.first { $0.id == SportType.baseball.rawValue }?.isSelected = true
        }
    }

    func test_imageDonloader() async {
        let store = TestStore(initialState: ResultsFeature.State(searchedModels: [SearchResult.dummy])) {
            ResultsFeature()
        } withDependencies: {
            $0.imageDownloader.fetch = { path in
                return UIImage(systemName: "photo.on.rectangle")?.pngData()
            }
        }

        await store.send(.listRowTapped(SearchResultViewModel(id: "AZg49Et9", name: "", sport: "", imageData: UIImage(systemName: "photo.on.rectangle")?.pngData()))) {
            $0.isLoading = false
            let viewModel = DetailViewModel(result: .dummy, imageData: UIImage(systemName: "photo.on.rectangle")?.pngData())
            $0.destination = .detail(DetailFeature.State(detail: viewModel))
        }
    }
}

extension SearchResult {
    static var dummy: SearchResult {
        SearchResult(id: "AZg49Et9", url: "djokovic-novak", name: "Djokovic Novak", gender: .init(id: 1, name: "Men"), type: .init(id: 3, name: "Player"), participantTypes: [.init(id: 2, name: "Player")], sport: .init(id: 2, name: "Tennis"), defaultCountry: .init(id: 167, name: "Serbia"), images: [.dummy])
    }
}

extension ResultImage {
    static var dummy: ResultImage {
        ResultImage(path: "6BtM40Br-xGFNNID8.png", usageId: 2, variantTypeId: 15)
    }
}
