//
//  UserViewControllerTest.swift
//  MVVM+CTests
//
//  Created by Alexander Jackson on 8/18/24.
//

import XCTest
@testable import MVVM_C

class UserViewControllerTests: XCTestCase {
    var viewController: UserViewController!
    var viewModel: UserViewModel!

    override func setUp() {
        super.setUp()
        viewModel = UserViewModel()
        viewController = UserViewController(viewModel: viewModel)
        viewController.loadViewIfNeeded()
    }

    override func tearDown() {
        viewController = nil
        viewModel = nil
        super.tearDown()
    }

    func testApplySnapshot() {
        let users = [
            User(id: 1, name: "Alice", email: "alice@email.com"),
            User(id: 2, name: "Bob", email: "bob@email.com")
        ]
        viewModel.users = users
        
        viewController.testHooks.applySnapshot(with: users)
        
        let snapshot = viewController.testHooks.dataSource.snapshot()
        XCTAssertEqual(snapshot.numberOfItems, users.count, "The snapshot should have the same number of items as the users array.")
    }
}
