//
//  SearchResult.swift
//  Livesport
//
// Created by Marek Hajdučák on 15/09/2023.
//

import Foundation

struct SearchResult: Codable, Equatable, Hashable {
    let id: String
    let url: String
    let name: String
    let gender: Namable
    let type: Namable
    let participantTypes: [Namable]
    let sport: Namable
    let defaultCountry: Namable
    let images: [ResultImage]
}

struct Namable: Codable, Equatable, Hashable {
    let id: Int
    let name: String
}

struct ResultImage: Codable, Equatable, Hashable {
    let path: String
    let usageId: Int
    let variantTypeId: Int
}
