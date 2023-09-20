//
//  SportGroupedList.swift
//  Livesport
//
//  Created by Marek Hajdučák on 18/09/2023.
//

import SwiftUI
import ComposableArchitecture

struct SportGroupedList: View {
    var items: [SearchResultViewModel]
    @BindingState var emptyState: EmptyState

    var selection: (SearchResultViewModel) -> Void

    private func groupByCategory(_ items: [SearchResultViewModel]) -> [(String, [SearchResultViewModel])] {
        let grouped = Dictionary(grouping: items, by: { $0.sport })
        return grouped.sorted(by: { $0.key < $1.key })
    }

    var body: some View {
        List {
            ForEach(groupByCategory(items), id: \.0) { pair in
                Section(header: Text(pair.0)) {
                    ForEach(pair.1) { item in
                        Button {
                            selection(item)
                        } label: {
                            HStack(spacing: 8) {
                                if let data = item.imageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                } else {
                                    Image("image-placeholder")
                                        .resizable()
                                        .frame(width: 16, height: 15)
                                }
                                Text(item.name)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color(.systemGray2))
                            }
                                .modifier(FlexWidthModifier(alignment: .leading))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
            .listStyle(.grouped)
            .emptyPlaceholder(items) {
                EmptySearchView(state: emptyState)
            }
    }
}

struct SportGroupedList_Previews: PreviewProvider {
    static var previews: some View {
        SportGroupedList(
            items: [
                SearchResultViewModel(id: "1", name: "Robert", sport: "Tenis", imageData: nil),
                SearchResultViewModel(id: "2", name: "Marek", sport: "Tenis", imageData: nil),
                SearchResultViewModel(id: "3", name: "Ivan", sport: "Tenis", imageData: nil),
                SearchResultViewModel(id: "4", name: "Kika", sport: "Bowling", imageData: nil),
                SearchResultViewModel(id: "5", name: "Veronika", sport: "Bowling", imageData: nil),
                SearchResultViewModel(id: "6", name: "Michal", sport: "Futbal", imageData: nil),
            ], emptyState: .empty, selection: { _ in }
        )
    }
}
