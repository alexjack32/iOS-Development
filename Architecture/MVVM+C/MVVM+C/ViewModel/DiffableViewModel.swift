//
//  DiffableViewModel.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/25/24.
//

import Foundation
import Combine
import UIKit

class DiffableViewModel {
    
    // Use a 1D array instead of a 2D array
    @Published var sectionData: [MyCustomModel] = []
    
    // PassthroughSubject for the snapshot
    var snapshotSubject = PassthroughSubject<NSDiffableDataSourceSnapshot<Int, MyCustomModel>, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen to changes in sectionData and send snapshot when data changes
        $sectionData
            .sink { [weak self] updatedData in
                print("Filtered Section data: \(updatedData.count) items")  // Debugging
                self?.sendSnapshot(with: updatedData)
            }
            .store(in: &cancellables)
    }
    
    // Populate with MyCustomModel data types
    func loadData() {
        sectionData = [
            .stringItem("Item 1"),
            .stringItem("Item 2"),
            .intItem(10),
            .intItem(20),
            .boolItem(true),
            .boolItem(false)
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            if let self {
                let moreData: [MyCustomModel] = [
                    .stringItem("Item 3"),
                    .stringItem("Item 4"),
                    .intItem(30),
                    .intItem(40),
                    .stringItem("Item 5"),
                    .stringItem("Item 6"),
                    .intItem(50),
                    .intItem(60),
                    
                ]
                self.sectionData.append(contentsOf: moreData)
            }
        }
        
    }

    
    // Create and send snapshot
    func sendSnapshot(with data: [MyCustomModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, MyCustomModel>()
        
        // Since we have only one section (Section 0)
        snapshot.appendSections([0])
        snapshot.appendItems(data, toSection: 0)
        
        print("Sent snapshot with \(snapshot.numberOfItems) items")
        snapshotSubject.send(snapshot)
    }
}

enum MyCustomModel: Hashable, Sendable {
    case stringItem(String)
    case intItem(Int)
    case boolItem(Bool)
}
