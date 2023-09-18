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
        var result: [SearchResult] = [] // TODO: empty view
        var isLoading: Bool = false
        var isSearchValid: Bool?
        @PresentationState var alert: AlertState<Action.Alert>?
    }

    enum Action: Equatable {
        case searchResponse(TaskResult<[SearchResult]>)
        case searchButtonTapped
        case filterButtonTapped
        // case binding(BindingAction<String>) // How to use BindableAction and BindingReducer?
        case textChange(String)
        case alert(PresentationAction<Alert>)
        enum Alert: Equatable {
            case retrySearch
        }
    }
    
    @Dependency(\.search) var search

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .searchButtonTapped, .alert(.presented(.retrySearch)):
                guard state.search.count >= 2 else {
                    state.isSearchValid = false
                    return .none
                }
                state.isSearchValid = true
                state.result = []
                state.isLoading = true
                return .run { [search = state.search] send in
                    await send(.searchResponse(
                        TaskResult { try await self.search.fetch(search) }
                    ))
                }
            case let .searchResponse(.success(result)):
                state.result = result
                state.isLoading = false
                return .none
            case .alert:
                return .none
            case let .searchResponse(.failure(error)):
                state.result = []
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
