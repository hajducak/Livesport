//
//  EmptyView.swift
//  Livesport
//
//  Created by Marek Hajdučák on 18/09/2023.
//

import SwiftUI
import ComposableArchitecture

enum EmptyState: Equatable {
    case empty
    case emptySearch
    case errorSearch(String)

    var title: String {
        switch self {
        case .empty: return "Find new results by entering term in the search box."
        case .emptySearch: return "No data exists for the entered input."
        case .errorSearch(_): return "An error occurred while searching:"
        }
    }

    var description: String? {
        switch self {
        case .empty, .emptySearch: return nil
        case .errorSearch(let error): return "\(error)"
        }
    }
}

struct EmptySearchView: View {
    @BindingState var state: EmptyState

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Image("empty-search")
            Text(state.title)
                .multilineTextAlignment(.center)
                .font(Font.title3).bold()
            state.description.map {
                Text($0)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
            .padding(.horizontal, 10)
            .modifier(FlexWidthModifier())
    }
}

struct EmptySearchView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptySearchView(state: .empty)
            EmptySearchView(state: .emptySearch)
            EmptySearchView(state: .errorSearch("One or more values are invalid"))
        }
    }
}


struct EmptyPlaceholderModifier<Items: Collection>: ViewModifier {
    let items: Items
    let placeholder: AnyView

    @ViewBuilder func body(content: Content) -> some View {
        if !items.isEmpty {
            content
        } else {
            placeholder
        }
    }
}

extension View {
    func emptyPlaceholder<Items: Collection, PlaceholderView: View>(
        _ items: Items,
        _ placeholder: @escaping () -> PlaceholderView
    ) -> some View {
        modifier(EmptyPlaceholderModifier(items: items, placeholder: AnyView(placeholder())))
    }
}


struct FlexWidthModifier: ViewModifier {

    let alignment: Alignment
    init(alignment: Alignment = .center) {
        self.alignment = alignment
    }

    func body(content: Content) -> some View {
        content.frame(minWidth: 0, maxWidth: .infinity, alignment: alignment)
    }
}

