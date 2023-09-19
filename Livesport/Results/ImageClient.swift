//
//  ImageClient.swift
//  Livesport
//
//  Created by Marek Hajdučák on 15/09/2023.
//

import ComposableArchitecture
import SwiftUI
import Foundation

struct ImageClient {
    var fetch: (String) async throws -> Data?
}

extension ImageClient: DependencyKey {
    static let liveValue = Self(
        fetch: { path in
            guard let url = URL(string: "https://www.livesport.cz/res/image/data/\(path)") else { return nil }
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
    )
}

extension DependencyValues {
    var imageDownloader: ImageClient {
        get { self[ImageClient.self] }
        set { self[ImageClient.self] = newValue }
    }
}
