//
//  ViewModelTests.swift
//  LivesportTests
//
//  Created by Marek Hajdučák on 20/09/2023.
//

import XCTest
import ComposableArchitecture

@testable import Livesport

class ViewModelTests: XCTestCase {
    
    func test_searchResultViewModel() {
        let imageResult = ResultImage(path: "6BtM40Br-xGFNNID8.png", usageId: 2, variantTypeId: 15)
        let searchResult = SearchResult(
            id: "dummyId",
            url: "dummyUrl",
            name: "dummyName",
            gender: .init(id: 1, name: "dummyGender"),
            type: .init(id: 2, name: "dummyType"),
            participantTypes: [.init(id: 3, name: "dummy1")],
            sport: .init(id: 4, name: "dummySport"),
            defaultCountry: .init(id: 5, name: "dummyCountry"),
            images: [imageResult]
        )
        
        let imageData = Data()
        
        let searchResultViewModel = SearchResultViewModel(result: searchResult, imageData: imageData)
        
        XCTAssertEqual(searchResultViewModel.id, "dummyId")
        XCTAssertEqual(searchResultViewModel.name, "dummyName")
        XCTAssertEqual(searchResultViewModel.sport, "dummySport")
        XCTAssertEqual(searchResultViewModel.imageData, imageData)
    }

    func test_detailViewModel() {
        let imageResult = ResultImage(path: "6BtM40Br-xGFNNID8.png", usageId: 2, variantTypeId: 15)
        let searchResult = SearchResult(
            id: "dymmyId",
            url: "dummyUrl",
            name: "dummyName",
            gender: .init(id: 1, name: "dummyGender"),
            type: .init(id: 2, name: "dummyType"),
            participantTypes: [.init(id: 3, name: "dummy1")],
            sport: .init(id: 4, name: "dummySport"),
            defaultCountry: .init(id: 5, name: "dummyCountry"),
            images: [imageResult]
        )
        let imageData = Data()
        
        let detailViewModel = DetailViewModel(result: searchResult, imageData: imageData)
        
        // Check if the properties are set correctly
        XCTAssertEqual(detailViewModel.id, "dymmyId")
        XCTAssertEqual(detailViewModel.name, "dummyName")
        XCTAssertEqual(detailViewModel.sport, "dummySport")
        XCTAssertEqual(detailViewModel.gender, "dummyGender")
        XCTAssertEqual(detailViewModel.type, "dummyType")
        XCTAssertEqual(detailViewModel.participantTypes, ["dummy1"])
        XCTAssertEqual(detailViewModel.defaultCountry, "dummyCountry")
        XCTAssertEqual(detailViewModel.imageData, imageData)
    }
}
