//
//  PokemonModel.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import Foundation

struct PokemonModel: Decodable {
    let count: Int
    let results: [Pokemon]
}

struct Pokemon: Decodable {
    let name: String
    let url: String
    
    // Computed property to extract the ID from the URL
    var id: Int {
        // Split the URL by "/" and extract the second-to-last component (which is the ID)
        return Int(url.split(separator: "/").last(where: { !$0.isEmpty }) ?? "") ?? 0
    }
}
