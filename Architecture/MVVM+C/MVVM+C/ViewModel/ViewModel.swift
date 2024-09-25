//
//  ViewModel.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 8/17/24.
//

import Combine
import UIKit

class PokemonViewModel {
    @Published var items: [Pokemon] = []
    let networkClient = PokemonNetwork()
    var cache: [Int: UIImage] = [:]
    var isLoading = false
    var hasData = true
    var cancellables = Set<AnyCancellable>()
    
    // PassthroughSubject to emit newly fetched Pokémon
    var newPokemonSubject = PassthroughSubject<[Pokemon], Never>()
    
    // Track ongoing image fetch requests
    var ongoingImageRequests: [Int: AnyCancellable] = [:]
    
    func loadPokemonData() {
            guard !isLoading, hasData else { return }
            isLoading = true
            
            // Fetch the next batch of Pokémon data using Combine
            networkClient.fetchNextPokemonList()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    self.isLoading = false
                    switch completion {
                    case .failure(let error):
                        print("Failed to fetch Pokémon list: \(error)")
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] newPokemons in
                    guard let self = self else { return }
                    self.items.append(contentsOf: newPokemons)
                    
                    // Send new Pokémon to the PassthroughSubject
                    self.newPokemonSubject.send(newPokemons)
                    
                    // If the batch is empty, assume no more data is available
                    if newPokemons.isEmpty {
                        self.hasData = false
                    }
                    
                })
                .store(in: &cancellables)
        }
}
