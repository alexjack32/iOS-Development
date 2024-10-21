//
//  Untitled.swift
//  DD4Y+SwiftUI
//
//  Created by Alexander Jackson on 10/15/24.
//

import XCTest
import SwiftUI
@testable import DD4Y_SwiftUI

// Define a simple data model for testing
struct TestItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
}

// Test case for the reusable collection view
class ReusableCollectionViewTests: XCTestCase {

    // Test that the collection view can display items
    func testCollectionViewDisplaysItems() {
        let items = [TestItem(title: "Item 1"), TestItem(title: "Item 2")]
        let collectionView = ReusableCollectionView(items: items) { item in
            Text(item.title)
        }
        
        let host = UIHostingController(rootView: collectionView)
        XCTAssertNotNil(host.view) // Ensure the view is rendered
    }

    // Test that the collection view displays the correct number of items
    func testCollectionViewDisplaysCorrectNumberOfItems() {
        let items = [TestItem(title: "Item 1"), TestItem(title: "Item 2"), TestItem(title: "Item 3")]
        let collectionView = ReusableCollectionView(items: items) { item in
            Text(item.title)
        }

        XCTAssertEqual(collectionView.items.count, 3) // Expect 3 items
    }
}
