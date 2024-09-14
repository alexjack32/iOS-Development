//
//  ViewModel.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 8/17/24.
//
//
//import Foundation
//import Combine
//
//class UserViewModel {
//    @Published var users: [User] = []
//    private var cancellables = Set<AnyCancellable>()
//    
//    init() {
//        loadInitialData()
//    }
//    
//    private func loadInitialData() {
//        fetchMockItems()
//            .sink(receiveCompletion: { completion in
//                print("Initial data load completed: \(completion)")
//            }, receiveValue: { [weak self] users in
//                self?.users = users
//            })
//            .store(in: &cancellables) // Store cancellable to manage the subscription
//    }
//    
//    func loadMoreData() {
//        fetchMockMoreItems()
//            .sink(receiveCompletion: { completion in
//                print("More data load completed: \(completion)")
//            }, receiveValue: { [weak self] newItems in
//                self?.users.append(contentsOf: newItems)
//            })
//            .store(in: &cancellables) // Store cancellable to manage the subscription
//    }
//    
//    private func fetchMockItems() -> AnyPublisher<[User], Never> {
//        return Future<[User], Never> { promise in
//            // Simulate network delay
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                let initialItems = [
//                    User(id: 1, name: "Item 1", email: ""),
//                    User(id: 2, name: "Item 2", email: ""),
//                    User(id: 3, name: "Item 3", email: "")
//                ]
//                promise(.success(initialItems))
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    private func fetchMockMoreItems() -> AnyPublisher<[User], Never> {
//        return Future<[User], Never> { promise in
//            // Simulate network delay for loading more data
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                let moreItems = [
//                    User(id: 4, name: "Item 4", email: ""),
//                    User(id: 5, name: "Item 5", email: ""),
//                    User(id: 6, name: "Item 6", email: "")
//                ]
//                promise(.success(moreItems))
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//}
// 
