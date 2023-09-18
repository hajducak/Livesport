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
                                .foregroundColor(Color(.systemGray))
                            TextField(
                                "Vyhľadaj výsledky",
                                text: viewStore.binding(get: { $0.search }, send: ResultsFeature.Action.textChange)
                            )
                            Button {
                                viewStore.send(.searchButtonTapped)
                            } label: {
                                Text("Search")
                                    .foregroundColor(.white)
                                    .padding(6)
                            }
                                .background(Color(UIColor.systemBlue)
                                    .cornerRadius(8))
                                .padding(4)
                                
                        }
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
                                .stroke(.red, lineWidth: viewStore.isSearchValid ?? true ? 0 : 2)
                        )
                            .animation(.default, value: viewStore.isSearchValid)
                            .padding(.horizontal)

                    VStack(alignment: .leading) {
                        if viewStore.isLoading {
                            LoadingView()
                        } else {
                            List(viewStore.result) { item in
                                Text(item.name)
                            }
                                .emptyPlaceholder(viewStore.result) {
                                    EmptySearchView(state: viewStore.emptyState)
                                }
                        }
                    }
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
            .alert(
                store: self.store.scope(
                    state: \.$alert,
                    action: { .alert($0) }
                )
            )
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView(
            store: Store(
                initialState: ResultsFeature.State(search: "dj", emptyState: .errorSearch("One or more values are missing!"))
            ) {
                ResultsFeature()
            }
        )
    }
}
