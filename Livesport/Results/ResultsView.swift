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
                        HStack(alignment: .center, spacing: 4) {
                            HStack(alignment: .center, spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title3)
                                    .padding(.leading, 8)
                                    .foregroundColor(Color(.systemGray))
                                TextField(
                                    "Vyhľadaj výsledky",
                                    text: viewStore.binding(get: { $0.search }, send: ResultsFeature.Action.textChange)
                                )
                            }
                                .frame(height: 48)
                                .background(Color(.systemGray4).cornerRadius(8, corners: [.bottomLeft, .topLeft]))
                            
                            Button {
                                viewStore.send(.searchButtonTapped)
                            } label: {
                                Text("Search")
                                    .foregroundColor(.white)
                            }
                                .frame(height: 48)
                                .padding(.horizontal, 8)
                                .background(Color(UIColor.systemBlue).cornerRadius(8, corners: [.bottomRight, .topRight]))
                        }
                            
                        if let isValid = viewStore.isSearchValid, !isValid {
                            Text("Dĺžka vyhľadávania musí mať aspoň 2 znaky.")
                                .font(Font.caption).bold()
                                .foregroundColor(.white)
                                .padding(.bottom, 6)
                                .padding(.horizontal, 8)
                        }
                    }
                        .background(
                            Color.red.opacity((viewStore.isSearchValid ?? true) ? 0 : 1).cornerRadius(8)
                        ).overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.red, lineWidth: viewStore.isSearchValid ?? true ? 0 : 2)
                        )
                            .animation(.default, value: viewStore.isSearchValid)
                            .padding(.horizontal)
                    VStack(alignment: .leading) {
                        HStack(spacing: 8) {
                            ForEach(viewStore.typeFilters, id: \.self) { viewModel in
                                FilterTag(viewModel: viewModel, selection: { model in
                                    viewStore.send(.typeFilterTagSelected(model.id))
                                })
                            }
                        }
                            .padding(.horizontal)
                        VStack(alignment:. leading, spacing: 8) {
                            Text("Sports:")
                                .font(.headline).bold()
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .center, spacing: 8) {
                                    ForEach(viewStore.sportFilters.indices, id: \.self) { index in
                                        FilterTag(viewModel: viewStore.sportFilters[index], selection: { model in
                                            viewStore.send(.sportFilterTagSelected(model.id))
                                        })
                                    }
                                }
                            }
                        }
                            .padding(.horizontal)
                        if viewStore.isLoading {
                            LoadingView()
                        } else {
                            SportGroupedList(items: viewStore.searchedData, emptyState: viewStore.emptyState)
                        }
                    }
                    Spacer()
                }
                    .navigationTitle("Výsledky")
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
