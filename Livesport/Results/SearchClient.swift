//
//  SearchClient.swift
//  Livesport
//
//  Created by Marek Hajdučák on 15/09/2023.
//

import Foundation
import ComposableArchitecture

struct SearchClient {
    var fetch: (String) async throws -> [SearchResult]
}

extension SearchClient: DependencyKey {
    static let liveValue = Self(
        fetch: { search in
            let (data, _) = try await URLSession.shared
                .data(from: URL(string: "https://s.livesport.services/api/v2/search?type-ids=2,3&project-type-id=1&project-id=602&lang-id=1&q=dj&sport-ids=1,2,3,4,5,6,7,8,9")!)

            if let JSONString = String(data: data, encoding: String.Encoding.utf8) {
               print(JSONString)
            }

            let result = try JSONDecoder().decode([SearchResult].self, from: data)
            return result
        }
    )
}

extension DependencyValues {
    var search: SearchClient {
        get { self[SearchClient.self] }
        set { self[SearchClient.self] = newValue }
    }
}
