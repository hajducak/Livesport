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

    init(id: String, name: String, sport: String) {
        self.id = id
        self.name = name
        self.sport = sport
    }
}

struct ResultsFeature: Reducer {
    struct State: Equatable {
        @BindingState var search = ""
        @BindingState var emptyState: EmptyState = .empty
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
        var isLoading: Bool = false
        var isSearchValid: Bool?
        @PresentationState var alert: AlertState<Action.Alert>?
    }

    enum Action: Equatable {
        case searchResponse(TaskResult<[SearchResult]>)
        case typeFilterTagSelected(String)
        case sportFilterTagSelected(String)
        case searchButtonTapped
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
                return .run { [search = state.search, typeIds = state.selectedTypeFilter, sportIds = state.selectedSportFilter] send in
                    await send(.searchResponse(
                        TaskResult { try await self.searchDownloader.fetch(search, typeIds, sportIds) }
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
            }
        }.ifLet(\.$alert, action: /Action.alert)
    }
}
