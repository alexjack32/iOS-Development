//
//  PokemonNetwork.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//
import Foundation
import Combine
import UIKit

class PokemonNetwork {
    private var currentOffset = 0
    private let limit = 20 // Number of items to fetch per request
    private var totalPokemon = 1302 // Default total count, will be updated dynamically
    
    func fetchPokemonList(offset: Int = 0, limit: Int = 20) -> AnyPublisher<PokemonModel, Error> {
        let urlString = "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(limit)"
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PokemonModel.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func fetchNextPokemonList() -> AnyPublisher<[Pokemon], Error> {
        guard currentOffset < totalPokemon else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let publisher = fetchPokemonList(offset: currentOffset, limit: limit)
            .handleEvents(receiveOutput: { [weak self] response in
                self?.totalPokemon = response.count // Update the total count dynamically
                self?.currentOffset += self?.limit ?? 0 // Increment the offset after successful fetch
            })
            .map { $0.results }
            .eraseToAnyPublisher()
        
        return publisher
    }
    
    func resetPagination() {
        currentOffset = 0
    }
    
    func fetchPokemonImage(for id: Int) -> AnyPublisher<UIImage?, Never> {
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
        guard let url = URL(string: imageUrlString) else {
            return Just(nil)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
