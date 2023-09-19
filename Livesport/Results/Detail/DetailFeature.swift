//
//  DetailFeature.swift
//  Livesport
//
//  Created by Marek Hajdučák on 19/09/2023.
//

import ComposableArchitecture
import SwiftUI
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


struct DetailFeature: Reducer {
    struct State: Equatable {
        var detail: DetailViewModel
    }

    enum Action: Equatable {}

    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {}
        }
    }
}
