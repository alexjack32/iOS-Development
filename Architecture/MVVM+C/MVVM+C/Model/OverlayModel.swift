//
//  OverlayModel.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 11/2/24.
//

import Foundation

struct OverlayModel: Codable {
    let data: [OverlayData]
}

struct OverlayData: Codable, Hashable {
    static func == (lhs: OverlayData, rhs: OverlayData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let title: String
    let id: String
    let coords: Coordinates
}

struct Coordinates: Codable {
    let x: String
    let y: String
}
