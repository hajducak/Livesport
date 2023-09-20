//
//  DetailFeature.swift
//  Livesport
//
//  Created by Marek Hajdučák on 19/09/2023.
//

import ComposableArchitecture
import SwiftUI
import Foundation

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
