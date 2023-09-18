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
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.title3)
                                .padding(.leading, 8)
                                .foregroundColor(Color(UIColor.systemGray))
                            TextField(
                                "Vyhľadaj výsledky",
                                text: viewStore.binding(get: { $0.search }, send: ResultsFeature.Action.textChange)
                            )
                            Button {
                                viewStore.send(.searchButtonTapped)
                            } label: {
                                Text("Vyhľadaj")
                                    .foregroundColor(.white)
                                    .padding(6)
                            }
                                .background(Color(UIColor.systemBlue)
                                    .cornerRadius(8))
                                .padding(4)
                                
                        }
                            //.padding(.vertical, 8)
                            .background(Color(.systemGray3).cornerRadius(8))
                        if let isValid = viewStore.isSearchValid, !isValid {
                            Text("Dĺžka vyhľadávania musí mať aspoň 2 znaky.")
                                .font(Font.caption).bold()
                                .foregroundColor(.white)
                                .padding(.bottom, 6)
                                .padding(.horizontal, 8)
                        }
                    }
                        .background(
                            Color.red.cornerRadius(8)
                        ).overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: viewStore.isSearchValid ?? true ? 0 : 2)
                        )
                            .animation(.default, value: viewStore.isSearchValid)
                            .padding(.horizontal)

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

struct ValidationModifier: ViewModifier {
    @Binding var isValid: Bool
    var text: String?

    func body(content: Content) -> some View {
        
            // .animation(.default)
    }
}
