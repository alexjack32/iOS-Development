//
//  CollectionView.swift
//  DD4Y+SwiftUI
//
//  Created by Alexander Jackson on 10/15/24.
//

import SwiftUI

public struct ReusableCollectionView<Item: Identifiable, Content: View>: View {
    public let items: [Item]
    public let content: (Item) -> Content

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    // Marking the initializer as public
    public init(items: [Item], @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self.content = content
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    content(item)
                }
            }
            .padding()
        }
    }
}
