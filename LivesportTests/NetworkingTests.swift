//
//  NetworkingTests.swift
//  LivesportTests
//
//  Created by Marek Hajdučák on 20/09/2023.
//

import XCTest
import ComposableArchitecture
import Combine
@testable import Livesport

@MainActor
class ImageClientTests: XCTestCase {
    let sut = ImageClient.liveValue

    func test_imageClientFetchSuccess() {
        let expectation = XCTestExpectation(description: "Image fetch completed")

        Task {
            do {
                if let data = try await sut.fetch("6BtM40Br-xGFNNID8.png") {
                    XCTAssertNotNil(data)
                    expectation.fulfill()
                } else {
                    XCTFail("Failed to fetch image data")
                }
            } catch {
                XCTFail("Image fetch error: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

@MainActor
class SearchClientTests: XCTestCase {
    let sut = SearchClient.liveValue

    func test_searchClientFetch() {
        let expectation = XCTestExpectation(description: "Search fetch completed")

        Task {
            do {
                let searchQuery = "dj"
                let competition: CompetitionType = .all
                let sport: SportType = .all

                let results = try await sut.fetch(searchQuery, competition, sport)

                XCTAssertFalse(results.isEmpty)
                expectation.fulfill()
            } catch {
                XCTFail("Search fetch error: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func test_searchClientFetchFailure() {
        let expectation = XCTestExpectation(description: "Search fetch failed")

        Task {
            do {
                let searchQuery = "a"
                let competition: CompetitionType = .participants
                let sport: SportType = .americanFootball
                
                let results = try await sut.fetch(searchQuery, competition, sport)

                XCTAssertTrue(results.isEmpty)
                expectation.fulfill()
            } catch {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }
}

@MainActor
class URLMakerTests: XCTestCase {
    var sut: URLMaker = URLMaker()

    func test_urlMakerEndpoint() {
        let search = "dj"
        let competition: CompetitionType = .participants
        let sport: SportType = .all
        
        let validURL = sut.endpoint(search: search, competition: competition, sport: sport)
        XCTAssertNotNil(validURL)

        let urlString = validURL?.absoluteString
        XCTAssertTrue(urlString?.contains("q=\(search)") ?? false)
        XCTAssertTrue(urlString?.contains("type-ids=\(competition.rawValue)") ?? false)
        XCTAssertTrue(urlString?.contains("sport-ids=\(sport.rawValue)") ?? false)
    }
}
