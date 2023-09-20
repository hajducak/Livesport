//
//  LivesportApp.swift
//  Livesport
//
//  Created by Marek Hajdučák on 14/09/2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct LivesportApp: App {
    static let store = Store(initialState: ResultsFeature.State()) {
        ResultsFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            ResultsView(
                store: LivesportApp.store
            )
        }
    }
}
