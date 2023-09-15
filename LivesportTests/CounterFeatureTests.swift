//
//  CounterFeatureTests.swift
//  LivesportTests

import ComposableArchitecture
import XCTest

@testable import Livesport

@MainActor
final class CounterFeatureTests: XCTestCase {
    // We just tested one of the most important responsibilities of the reducer, and that is how it mutates state when it processes an action.
    func testCounter() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }

        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }

    func testTimer() async {
        let clock = TestClock()

        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }
        await clock.advance(by: .seconds(1))
        await store.receive(.timerTick) {
            $0.count = 1
        }
        await store.send(.toggleTimerButtonTapped) {
          $0.isTimerRunning = false
        }
    }

    func testNumberFact() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.numberFact.fetch = { "\($0) is a good number." }
        }

        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }
        await store.receive(.factResponse("0 is a good number.")) {
            $0.isLoading = false
            $0.fact = "0 is a good number."
          }
    }
}
