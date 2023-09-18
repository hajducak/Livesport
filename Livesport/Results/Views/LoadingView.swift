//
//  LoadingView.swift
//  Livesport
//
//  Created by Marek Hajdučák on 18/09/2023.
//

import SwiftUI

struct LoadingView: View {
    var loadingText: String = "Downloading..."

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ProgressView(loadingText)
                    .controlSize(.large)
                    .font(.title3)
                Spacer()
            }
            Spacer()
        }
    }
}
