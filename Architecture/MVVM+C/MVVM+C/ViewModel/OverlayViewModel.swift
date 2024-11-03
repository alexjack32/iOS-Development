//
//  OverlayViewModel.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 11/2/24.
//

import Foundation

class OverlayViewModel: ObservableObject {
    @Published var items: [OverlayData] = []
    
    func loadItems() {
        do {
            if let url = Bundle.main.url(forResource: "Overlay", withExtension: "json") {
                let response = try JSONDecoder().decode(OverlayModel.self, from: try Data(contentsOf: url))
                self.items = response.data
//                print(self.items)
            }
        } catch {
            print("Error decodeing mock data: \(error.localizedDescription)")
        }
    }
}
