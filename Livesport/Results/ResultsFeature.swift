//
//  ResultsFeature.swift
//  Livesport
//
//  Created by Marek Hajdučák on 15/09/2023.
//
// NOTES:
// 1. How to use BindableAction and BindingReducer? - case binding(BindingAction<String>)
// 2. How to use path, NavigationStackPath to show navigation destination (Action: case path(StackAction<DetailFeature.State, DetailFeature.Action>), Reducer: .forEach(\.path, action: /Action.path) { DetailFeature() })
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

        var selectedSportFilter: SportType = .all
        var sportFilters: [FilterModel] = [
            SportType.all.filter,
            SportType.soccer.filter,
            SportType.tenis.filter,
            SportType.basketballl.filter,
            SportType.hockey.filter,
            SportType.americanFootball.filter,
            SportType.baseball.filter,
            SportType.handball.filter,
            SportType.rugby.filter,
            SportType.floorbal.filter
        ]
        var selectedCompetitionFilter: CompetitionType = .all
        var competitionFilters: [FilterModel] = [
            CompetitionType.all.filter,
            CompetitionType.competitions.filter,
            CompetitionType.participants.filter
        ]

        var searchedData: [SearchResultViewModel] = []
        var searchedModels: [SearchResult] = []
    }

    enum Action: Equatable {
        case searchResponse(TaskResult<[SearchResult]>)
        case imageResponseByResult([SearchResult: Data?])
        case typeFilterTagSelected(CompetitionType?)
        case sportFilterTagSelected(SportType?)
        case searchButtonTapped
        case textChange(String)
        case destination(PresentationAction<Destination.Action>)
        case listRowTapped(SearchResultViewModel)

        enum Alert: Equatable {
            case retrySearch
        }
    }

    @Dependency(\.searchData) var searchDownloader
    @Dependency(\.imageDownloader) var imageDownloader

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
                return .run { [search = state.search, competition = state.selectedCompetitionFilter, sport = state.selectedSportFilter] send in
                    await send(.searchResponse(
                        TaskResult { try await self.searchDownloader.fetch(search, competition, sport) }
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
            case let .typeFilterTagSelected(competition):
                guard let competition else { return .none }
                state.selectedCompetitionFilter = competition
                state.competitionFilters.forEach { $0.isSelected = false }
                state.competitionFilters.first { $0.id == competition.rawValue }?.isSelected = true
                return .none
            case let .sportFilterTagSelected(sport):
                guard let sport else { return .none }
                state.selectedSportFilter = sport
                state.sportFilters.forEach { $0.isSelected = false }
                state.sportFilters.first { $0.id == sport.rawValue }?.isSelected = true
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
