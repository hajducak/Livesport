//
//  DetailView.swift
//  Livesport
//
//  Created by Marek Hajdučák on 19/09/2023.
//

import SwiftUI
import ComposableArchitecture

struct DetailView: View {
    let store: StoreOf<DetailFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: \.detail) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let data = viewStore.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                    } else {
                        Image("image-placeholder")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(viewStore.name).font(Font.largeTitle).bold()
                    Text(viewStore.defaultCountry).font(Font.title)
                }

                VStack(spacing: 4) {
                    row(title: "Gender:", value: viewStore.gender)
                    row(title: "Sport:", value: viewStore.sport)
                    row(title: "Idividuality type:", value: viewStore.type)
                    row(title: "Specification:", value: viewStore.participantTypes.joined(separator: ", "))
                }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(UIColor.systemGray), lineWidth: 2)
                    ).background(
                        Color(UIColor.systemGray4).cornerRadius(8)
                    )
                Spacer()
            }
                .padding(20)
        }
    }

    private func row(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .multilineTextAlignment(.leading)
            Spacer()
            Text(value).font(.headline)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(
            store: Store(
                initialState: DetailFeature.State(
                    detail: DetailViewModel(
                        result: SearchResult(
                            id: "AZg49Et9",
                            url: "djokovic-novak",
                            name: "Djokovic Novak",
                            gender: .init(id: 1, name: "Men"),
                            type: .init(id: 3, name: "Player"),
                            participantTypes: [.init(id: 2, name: "Player")],
                            sport: .init(id: 2, name: "Tennis"),
                            defaultCountry: .init(id: 167, name: "Serbia"),
                            images: [
                                ResultImage(path: "6BtM40Br-xGFNNID8.png", usageId: 2, variantTypeId: 15)
                            ]
                        ),
                        imageData: nil
                    )
                )
            ) {
                DetailFeature()
            }
        )
    }
}
