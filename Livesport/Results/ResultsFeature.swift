//
//  ResultsFeature.swift
//  Livesport
//
//  Created by Marek Hajdučák on 15/09/2023.
//

import ComposableArchitecture

struct ResultsFeature: Reducer {
    struct State: Equatable {
        @BindingState var search = ""
        var result: [SearchResult] = []
        var isLoading: Bool = false
        var isSearchValid: Bool?
        // TODO: error handling - api error: add empty view and error view
    }

    enum Action: Equatable {
        case searchResponse([SearchResult])
        case searchButtonTapped
        case filterButtonTapped
        // case binding(BindingAction<String>) // How to use BindableAction and BindingReducer ?
        case textChange(String)
    }
    
    @Dependency(\.search) var search

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .searchButtonTapped:
                guard state.search.count >= 2 else {
                    state.isSearchValid = false
                    return .none
                }
                state.isSearchValid = true
                state.result = []
                state.isLoading = true
                return .run { [search = state.search] send in
                    try await send(.searchResponse(self.search.fetch(search)))
                }
            case let .searchResponse(result):
                state.result = result
                state.isLoading = false
                return .none
            case let .textChange(searchText):
                state.search = searchText
                return .none
            case .filterButtonTapped:
                return .none
            }
        }
    }
}
