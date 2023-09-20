//
//  SearchClient.swift
//  Livesport
//
//  Created by Marek Hajdučák on 15/09/2023.
//

import Foundation
import ComposableArchitecture

struct SearchClient {
    var fetch: (_ searchQuery: String, _ competition: CompetitionType, _ sport: SportType) async throws -> [SearchResult]
}

extension SearchClient: DependencyKey {
    static let liveValue = Self(
        fetch: { search, competition, sport in
            let urlMaker = URLMaker()
            guard let url = urlMaker.endpoint(search: search, competition: competition, sport: sport) else { return [] }
            let (data, _) = try await URLSession.shared.data(from: url)
            let result = try JSONDecoder().decode([SearchResult].self, from: data)
            return result
        }
    )
}

extension DependencyValues {
    var searchData: SearchClient {
        get { self[SearchClient.self] }
        set { self[SearchClient.self] = newValue }
    }
}

final class URLMaker {
    private let baseURL: String = "https://s.livesport.services/api/v2/search"

    func endpoint(search: String, competition: CompetitionType, sport: SportType) -> URL? {
        let params: [String: String] = [
            "lang-id": "1",
            "project-id": "602",
            "project-type-id": "1",
            "sport-ids" : sport.rawValue,
            "type-ids": competition.rawValue,
            "q": search
        ]
        let paramString: String = params.compactMap {(key, value) -> String in
            return "\(key)=\(value)"
        }.joined(separator: "&")

        return URL(string: baseURL.appending("?").appending(paramString))
    }
}

enum SportType: String, Equatable {
    case all = "1,2,3,4,5,6,7,8,9"
    case soccer = "1"
    case tenis = "2"
    case basketballl = "3"
    case hockey = "4"
    case americanFootball = "5"
    case baseball = "6"
    case handball = "7"
    case rugby = "8"
    case floorbal = "9"

    var filter: FilterModel {
        switch self {
        case .all: return FilterModel(id: self.rawValue, imageName: "tray.full.fill", title: "All", isSelected: true)
        case .soccer: return FilterModel(id: self.rawValue, imageName: nil, title: "Soccer")
        case .tenis: return FilterModel(id: self.rawValue, imageName: nil, title: "Tenis")
        case .basketballl: return FilterModel(id: self.rawValue, imageName: nil, title: "Basketballl")
        case .hockey: return FilterModel(id: self.rawValue, imageName: nil, title: "Hockey")
        case .americanFootball: return FilterModel(id: self.rawValue, imageName: nil, title: "American Football")
        case .baseball: return FilterModel(id: self.rawValue, imageName: nil, title: "Baseball")
        case .handball: return FilterModel(id: self.rawValue, imageName: nil, title: "Handball")
        case .rugby: return FilterModel(id: self.rawValue, imageName: nil, title: "Rugby")
        case .floorbal: return FilterModel(id: self.rawValue, imageName: nil, title: "Floorball")
        }
    }
}

enum CompetitionType: String, Equatable {
    case all = "1,2,3,4"
    case competitions = "1"
    case participants = "2,3,4"

    var filter: FilterModel {
        switch self {
        case .all: return FilterModel(id: "1,2,3,4", imageName: "tray.full.fill", title: "All", isSelected: true)
        case .competitions: return FilterModel(id: "1", imageName: "person.3.fill", title: "Competitions")
        case .participants: return FilterModel(id: "2,3,4", imageName: "person.fill", title: "Participants")
        }
    }
}
