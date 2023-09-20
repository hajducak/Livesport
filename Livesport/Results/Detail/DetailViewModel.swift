//
//  DetailViewModel.swift
//  Livesport
//
//  Created by Marek Hajdučák on 20/09/2023.
//

import Foundation

struct DetailViewModel: Equatable, Identifiable, Hashable {
    static func == (lhs: DetailViewModel, rhs: DetailViewModel) -> Bool {
        lhs.id == rhs.id
    }

    let id: String
    let name: String
    let sport: String
    let imageData: Data?
    let gender: String
    let type: String
    let participantTypes: [String]
    let defaultCountry: String

    init(result: SearchResult, imageData: Data?) {
        self.id = result.id
        self.name = result.name
        self.imageData = imageData
        self.sport = result.sport.name
        self.gender = result.gender.name
        self.type = result.type.name
        self.participantTypes = result.participantTypes.compactMap({ $0.name })
        self.defaultCountry = result.defaultCountry.name
    }
}
