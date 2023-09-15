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
    static let store = Store(initialState: CounterFeature.State()) {
        CounterFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            CounterView(
                store: LivesportApp.store
            )
        }
    }
}
