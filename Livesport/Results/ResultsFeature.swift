//
//  ResultsFeature.swift
//  Livesport
//
//  Created by Marek Hajdučák on 15/09/2023.
//
// NOTES:
// 1. How to use BindableAction and BindingReducer? - case binding(BindingAction<String>)
// 2. How to use two asynch task inside effects (.run)
//

import ComposableArchitecture

struct SearchResultViewModel: Equatable, Identifiable, Hashable {
    let id: String
    let name: String
    let sport: String
    // TODO: add image

    init(result: SearchResult) {
        self.id = result.id
        self.name = result.name
        self.sport = result.sport.name
    }

    init(
        id: String,
        name: String,
        sport: String
    ) {
        self.id = id
        self.name = name
        self.sport = sport
    }
}

struct ResultsFeature: Reducer {
    struct State: Equatable {
        @BindingState var search = ""
        @BindingState var emptyState: EmptyState = .empty
        var searchedData: [SearchResultViewModel] = []
        var isLoading: Bool = false
        var isSearchValid: Bool?
        @PresentationState var alert: AlertState<Action.Alert>?
    }
    
    
    enum Action: Equatable {
        case searchResponse(TaskResult<[SearchResult]>)
        case searchButtonTapped
        case filterButtonTapped
        case textChange(String)
        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case retrySearch
        }
    }

    @Dependency(\.searchData) var searchDownloader

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .searchButtonTapped, .alert(.presented(.retrySearch)):
                guard state.search.count >= 2 else {
                    state.isSearchValid = false
                    return .none
                }
                state.isSearchValid = true
                state.searchedData = []
                state.isLoading = true
                return .run { [search = state.search] send in
                    await send(.searchResponse(
                        TaskResult { try await self.searchDownloader.fetch(search) }
                    ))
                }
            case let .searchResponse(.success(results)):
                if results.isEmpty {
                    state.emptyState = .emptySearch
                }
                state.searchedData = results.compactMap({ SearchResultViewModel(result: $0) })
                state.isLoading = false
                return .none
            case .alert:
                return .none
            case let .searchResponse(.failure(error)):
                state.searchedData = []
                state.emptyState = .errorSearch(error.localizedDescription)
                state.isLoading = false
                state.alert = AlertState {
                    TextState("Vyskytla sa chyba: \(error.localizedDescription)")
                } actions: {
                    ButtonState(role: .destructive, action: .retrySearch) {
                        TextState("Znova")
                    }
                }
                return .none
            case let .textChange(searchText):
                state.search = searchText
                return .none
            case .filterButtonTapped:
                return .none
            }
        }.ifLet(\.$alert, action: /Action.alert)
    }
}
