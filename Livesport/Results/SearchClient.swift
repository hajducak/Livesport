//
//  SearchClient.swift
//  Livesport
//
//  Created by Marek Hajdučák on 15/09/2023.
//

import Foundation
import ComposableArchitecture

struct SearchClient {
    var fetch: (_ searchQuery: String, _ typeIds: String, _ sportIds: String) async throws -> [SearchResult]
}

extension SearchClient: DependencyKey {
    static let liveValue = Self(
        fetch: { search, typeIds, sportIds in
            let urlMaker = URLMaker()
            guard let url = urlMaker.endpoint(search: search, typeIds: typeIds, sportIds: sportIds) else { return [] }
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

    func endpoint(search: String, typeIds: String, sportIds: String) -> URL? {
        let params: [String: String] = [
            "lang-id": "1",
            "project-id": "602",
            "project-type-id": "1",
            "sport-ids" : sportIds,
            "type-ids": typeIds,
            "q": search
        ]
        let paramString: String = params.compactMap {(key, value) -> String in
            return "\(key)=\(value)"
        }.joined(separator: "&")

        return URL(string: baseURL.appending("?").appending(paramString))
    }
}
