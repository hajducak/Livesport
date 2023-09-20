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

    func test_ImageClientFetchSuccess() {
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

    func test_SearchClientFetch() {
        let expectation = XCTestExpectation(description: "Search fetch completed")

        Task {
            do {
                let searchQuery = "dj"
                let typeIds = "1,2,3,4"
                let sportIds = "1,2,3,4,5,6,7,8,9"

                let results = try await sut.fetch(searchQuery, typeIds, sportIds)

                XCTAssertFalse(results.isEmpty)
                expectation.fulfill()
            } catch {
                XCTFail("Search fetch error: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func test_SearchClientFetchFailure() {
        let searchClient = SearchClient.liveValue
        let expectation = XCTestExpectation(description: "Search fetch failed")

        Task {
            do {
                let searchQuery = "a"
                let typeIds = "0"
                let sportIds = "0"
                
                let results = try await sut.fetch(searchQuery, typeIds, sportIds)

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

    func test_URLMakerEndpoint() {
        let search = "dj"
        let typeIds = "2,3"
        let sportIds = "1,2,3,4,5,6,7,8,9"
        
        let validURL = sut.endpoint(search: search, typeIds: typeIds, sportIds: sportIds)
        XCTAssertNotNil(validURL)

        let urlString = validURL?.absoluteString
        XCTAssertTrue(urlString?.contains("q=\(search)") ?? false)
        XCTAssertTrue(urlString?.contains("type-ids=\(typeIds)") ?? false)
        XCTAssertTrue(urlString?.contains("sport-ids=\(sportIds)") ?? false)
    }
}
