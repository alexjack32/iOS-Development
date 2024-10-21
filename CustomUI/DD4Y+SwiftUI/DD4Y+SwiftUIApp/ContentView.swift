//
//  ContentView.swift
//  DD4Y+SwiftUIApp
//
//  Created by Alexander Jackson on 10/15/24.
//

import DD4Y_SwiftUI
import SwiftUI
struct Item: Identifiable, Equatable {
    let id: UUID = .init()
    let title: String
}
struct ContentView: View {
    let items = [
        Item(title: "Item 1"),
        Item(title: "Item 2"),
        Item(title: "Item 3"),
        Item(title: "Item 4"),
        Item(title: "Item 5"),
        Item(title: "Item 6"),
        Item(title: "Item 7"),
        Item(title: "Item 8"),
        Item(title: "Item 9"),
        Item(title: "Item 10"),
    ]

    var body: some View {
        ReusableCollectionView(items: items) { item in
            VStack {
                Text(item.title)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    ContentView()
}
