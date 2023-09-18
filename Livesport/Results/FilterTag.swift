//
//  FilterTag.swift
//  Livesport
//
//  Created by Marek Hajdučák on 18/09/2023.
//

import SwiftUI

final class FilterModel: ObservableObject, Equatable, Identifiable, Hashable {
    static func == (lhs: FilterModel, rhs: FilterModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    @Published var isSelected: Bool
    var id: String
    var imageName: String?
    var title: String
    
    init(id: String, imageName: String?, title: String, isSelected: Bool = false) {
        self.id = id
        self.imageName = imageName
        self.title = title
        self.isSelected = isSelected
    }
}

struct FilterTag: View {
    @ObservedObject var viewModel: FilterModel
    var selection: (FilterModel) -> Void

    var body: some View {
        HStack(spacing: 4) {
            viewModel.imageName.map {
                Image(systemName: $0)
            }
            Text(viewModel.title)
        }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(viewModel.isSelected ? Color(.systemBlue) : Color(.systemGray4))
            ).onTapGesture {
                viewModel.isSelected.toggle()
                selection(viewModel)
            }
    }
}
