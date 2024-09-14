//
//  PokemonViewController.swift
//  MVVM+C
// vuXNgk6kYpCbuhCyh05EBHpHUUMumigHZTfx3QpyMg9onUiHGbmHmuLN
//  Created by Alexander Jackson on 9/13/24.
//

import Combine
import UIKit

class PokemonViewController: UIViewController {
    var collectionView: PokemonCollectionView!
    
    var items: [Pokemon] = []
    let networkClient = PokemonNetwork()
    var cache: [Int: UIImage] = [:]
    var isLoading = false
    var hasData = true
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = PokemonCollectionView(frame: .zero)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        
        loadPokemonData()
    }
    
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
                    
                    let startIndex = self.items.count
                    self.items.append(contentsOf: newPokemons)
                    
                    // If the batch is empty, assume no more data is available
                    if newPokemons.isEmpty {
                        self.hasData = false
                    }
                    
                    let endIndex = self.items.count
                    let indexPaths = (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
                    
                    // Perform batch updates to insert new data
                    self.collectionView.performBatchUpdates({
                        self.collectionView.insertItems(at: indexPaths)
                    }, completion: nil)
                })
                .store(in: &cancellables)
        }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func scrollToCenterFirstItem(animated: Bool) {
        if collectionView.contentOffset == .zero {
               let firstIndexPath = IndexPath(item: 0, section: 0)
               collectionView.scrollToItem(at: firstIndexPath, at: .centeredHorizontally, animated: animated)
           }
    }
}

extension PokemonViewController: UICollectionViewDelegate,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout,
                                 UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.item >= items.count - 1 }) {
            loadPokemonData() // Load more data when nearing the end of the list
        }
        
        for indexPath in indexPaths {
            let pokemon = items[indexPath.row]
            if cache[pokemon.id] == nil {
                networkClient.fetchPokemonImage(for: pokemon.id)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] image in
                        if let self {
                            self.cache[pokemon.id] = image
                        }
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCollectionViewCell.reuseIdentifier, for: indexPath) as? PokemonCollectionViewCell {
            
            let pokemon = items[indexPath.row]
            print(pokemon, pokemon.id)
            cell.configure(with: pokemon, image: nil)
            
            if let cachedImage = cache[pokemon.id] {
                cell.configure(with: pokemon, image: cachedImage)
            } else {
                networkClient.fetchPokemonImage(for: pokemon.id)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] image in
                        if let self {
                            self.cache[pokemon.id] = image
                            cell.configure(with: pokemon, image: image)
                        }
                    }
                    .store(in: &cancellables)
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }
}
