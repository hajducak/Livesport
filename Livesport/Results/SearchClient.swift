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
            let urlMaker = URLMaker()
            guard let url = urlMaker.endpoint(search: search) else {
                //TODO: error
                return []
            }
            let (data, response) = try await URLSession.shared.data(from: url)
            
        
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

final class URLMaker {
    private let baseURL: String = "https://s.livesport.services/api/v2/search"

    // Add sport-ids (sport) and type-ids (type of sport) filter
    func endpoint(search: String) -> URL? {
        let params: [String: String] = [
            "lang-id": "1",
            "project-id": "602",
            "project-type-id": "1",
            "sport-ids" : "1,2,3,4,5,6,7,8,9",
            "type-ids": "2,3",
            "q": "\(search)"
        ]
        let paramString: String = params.compactMap {(key, value) -> String in
            return "\(key)=\(value)"
        }.joined(separator: "&")

        return URL(string: baseURL.appending("?").appending(paramString))
    }
}
