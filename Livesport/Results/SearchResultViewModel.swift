//
//  SearchResultViewModel.swift
//  Livesport
//
//  Created by Marek Hajdučák on 20/09/2023.
//

import Foundation

struct SearchResultViewModel: Equatable, Identifiable, Hashable {
    let id: String
    let name: String
    let sport: String
    let imageData: Data?

    init(result: SearchResult, imageData: Data?) {
        self.id = result.id
        self.name = result.name
        self.sport = result.sport.name
        self.imageData = imageData
    }

    init(id: String, name: String, sport: String, imageData: Data?) {
        self.id = id
        self.name = name
        self.sport = sport
        self.imageData = imageData
    }
}
