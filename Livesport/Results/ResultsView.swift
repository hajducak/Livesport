//
//  ResultsView.swift
//  Livesport
//
//  Created by Marek Hajdučák on 15/09/2023.
//

import SwiftUI
import ComposableArchitecture

struct ResultsView: View {
    let store: StoreOf<ResultsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(alignment: .leading) {
                    HStack {
                        TextField(
                            "Vyhľadaj výsledky",
                            text: viewStore.binding(get: { $0.search }, send: ResultsFeature.Action.textChange)
                        )
                            .padding()
                        Button {
                            viewStore.send(.searchButtonTapped)
                        } label: {
                            Image(systemName: "magnifyingglass.circle.fill")
                        }
                            .font(.largeTitle)
                            .padding(.horizontal, 8)
                    }
                        .background(Color.gray.opacity(0.3).cornerRadius(8))
                        .padding()
                    VStack(alignment: .leading) {
                        if viewStore.isLoading {
                            LoadingView()
                        } else {
                            ForEach(viewStore.result, id: \.self) { result in
                                Text(result.name)
                            }
                        }
                    }
                        .padding()
                    Spacer()
                }
                    .navigationTitle("Výsledky")
                    .toolbar {
                        ToolbarItem {
                            Button {
                                viewStore.send(.filterButtonTapped)
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            }
                        }
                    }
            }
        }
    }
}

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

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(
            store: Store(
                initialState: ResultsFeature.State()
            ) {
                ResultsFeature()
            }
        )
    }
}
