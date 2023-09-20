//
//  ResultsFeature.swift
//  Livesport
//
//  Created by Marek Hajdučák on 15/09/2023.
//
// NOTES:
// 1. How to use BindableAction and BindingReducer? - case binding(BindingAction<String>)
// 3. How to use path, NavigationStackPath to show navigation destination (Action: case path(StackAction<DetailFeature.State, DetailFeature.Action>), Reducer: .forEach(\.path, action: /Action.path) { DetailFeature() })
//

import ComposableArchitecture
import Foundation

struct ResultsFeature: Reducer {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?

        @BindingState var search = ""
        @BindingState var emptyState: EmptyState = .empty

        var isLoading: Bool = false
        var isSearchValid: Bool?

        var selectedSportFilter: String = "1,2,3,4,5,6,7,8,9"
        var sportFilters: [FilterModel] = [
            FilterModel(id: "1,2,3,4,5,6,7,8,9", imageName: "tray.full.fill", title: "All", isSelected: true),
            FilterModel(id: "1", imageName: nil, title: "Soccer"),
            FilterModel(id: "2", imageName: nil, title: "Tenis"),
            FilterModel(id: "3", imageName: nil, title: "Basketballl"),
            FilterModel(id: "4", imageName: nil, title: "Hockey"),
            FilterModel(id: "5", imageName: nil, title: "American Football"),
            FilterModel(id: "6", imageName: nil, title: "Baseball"),
            FilterModel(id: "7", imageName: nil, title: "Handball"),
            FilterModel(id: "8", imageName: nil, title: "Rugby"),
            FilterModel(id: "9", imageName: nil, title: "Floorball")
        ]
        var selectedTypeFilter: String = "1,2,3,4"
        var typeFilters: [FilterModel] = [
            FilterModel(id: "1,2,3,4", imageName: "tray.full.fill", title: "All", isSelected: true),
            FilterModel(id: "1", imageName: "person.3.fill", title: "Competitions"),
            FilterModel(id: "2,3,4", imageName: "person.fill", title: "Participants")
        ]

        var searchedData: [SearchResultViewModel] = []
        var searchedModels: [SearchResult] = []
    }

    enum Action: Equatable {
        case searchResponse(TaskResult<[SearchResult]>)
        case imageResponseByResult([SearchResult: Data?])
        case typeFilterTagSelected(String)
        case sportFilterTagSelected(String)
        case searchButtonTapped
        case textChange(String)
        case destination(PresentationAction<Destination.Action>)
        case listRowTapped(SearchResultViewModel)

        enum Alert: Equatable {
            case retrySearch
        }
    }

    @Dependency(\.searchData) var searchDownloader
    @Dependency(\.imageDownloader) var  imageDownloader

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .searchButtonTapped, .destination(.presented(.alert(.retrySearch))):
                guard state.search.count >= 2 else {
                    state.isSearchValid = false
                    return .none
                }
                state.isSearchValid = true
                state.searchedData = []
                state.searchedModels = []
                state.isLoading = true
                return .run { [search = state.search, typeIds = state.selectedTypeFilter, sportIds = state.selectedSportFilter] send in
                    await send(.searchResponse(
                        TaskResult { try await self.searchDownloader.fetch(search, typeIds, sportIds) }
                    ))
                }
            case let .searchResponse(.success(results)):
                if results.isEmpty {
                    state.emptyState = .emptySearch
                    state.isLoading = false
                }
                // MARK: - 1. Not the best practice I gues but it is working (can't find how I can download image for every single result diferently and smoothly)
                let effects = results.compactMap({ result -> Effect<ResultsFeature.Action> in
                    return Effect.run(operation: { send in
                        try await send(.imageResponseByResult([result: self.imageDownloader.fetch(result.images.first(where: { $0.variantTypeId == 15 })?.path ?? "")]))
                    })
                })
                return .merge(effects)
            case let .imageResponseByResult(resultWithImageData):
                // MARK: - 2. The response is continues, effect by effect from searchResponse merge, so I need append element by element how they come with downloaded image.
                // MARK: I would love to make it that data will come in one peace together but i don't now how?
                state.searchedData.append(contentsOf: resultWithImageData.compactMap({ SearchResultViewModel(result: $0.key, imageData: $0.value) }))
                state.searchedModels.append(contentsOf: resultWithImageData.compactMap({ $0.key }))
                state.isLoading = false
                return .none
            case let .searchResponse(.failure(error)):
                state.searchedData = []
                state.searchedModels = []
                state.emptyState = .errorSearch(error.localizedDescription)
                state.isLoading = false
                state.destination = .alert(
                    AlertState {
                        TextState("Vyskytla sa chyba: \(error.localizedDescription)")
                    } actions: {
                        ButtonState(role: .destructive, action: .retrySearch) {
                            TextState("Znova")
                        }
                    }
                )
                return .none
            case let .textChange(searchText):
                state.search = searchText
                return .none
            case let .typeFilterTagSelected(id):
                state.selectedTypeFilter = id
                state.typeFilters.forEach { $0.isSelected = false }
                state.typeFilters.first { $0.id == id }?.isSelected = true
                return .none
            case let .sportFilterTagSelected(id):
                state.selectedSportFilter = id
                state.sportFilters.forEach { $0.isSelected = false }
                state.sportFilters.first { $0.id == id }?.isSelected = true
                return .none
            case let .listRowTapped(viewModelData):
                guard let detail = state.searchedModels.first(where: { $0.id == viewModelData.id }) else { return .none }
                let viewModel = DetailViewModel(result: detail, imageData: viewModelData.imageData)
                state.destination = .detail(DetailFeature.State(detail: viewModel))
                return .none
            case .destination:
                return .none
            }
        }
            .ifLet(\.$destination, action: /Action.destination) {
                Destination()
            }
    }
}

extension ResultsFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case detail(DetailFeature.State)
            case alert(AlertState<ResultsFeature.Action.Alert>)
        }

        enum Action: Equatable {
            case detail(DetailFeature.Action)
            case alert(ResultsFeature.Action.Alert)
        }

        var body: some ReducerOf<Self> {
            Scope(state: /State.detail, action: /Action.detail) {
                DetailFeature()
            }
        }
    }
}
