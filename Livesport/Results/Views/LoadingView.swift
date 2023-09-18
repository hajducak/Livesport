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
            ProgressView(loadingText)
                .controlSize(.large)
                .font(.title3)
            Spacer()
        }.modifier(FlexWidthModifier())
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingView()
            LoadingView(loadingText: "Loading...")
        }
    }
}
