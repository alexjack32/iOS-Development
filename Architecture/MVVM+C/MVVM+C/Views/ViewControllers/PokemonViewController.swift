//
//  PokemonViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import Combine
import UIKit

class PokemonViewController: UIViewController {
    var collectionView: PokemonCollectionView!
    var viewModel: PokemonViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PokemonViewModel()
        collectionView = PokemonCollectionView(frame: .zero)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        
        bindView()
        viewModel.loadPokemonData()
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
    
    private func bindView() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.performBatchUpdates()
            }
            .store(in: &viewModel.cancellables)
    }
    
    private func performBatchUpdates() {
            let itemCount = collectionView.numberOfItems(inSection: 0) // Items currently in the collection view
            let newItemCount = viewModel.items.count // Items in the view model
            
            guard newItemCount > itemCount else { return } // Ensure new items were added
            
            let indexPaths = (itemCount..<newItemCount).map { IndexPath(item: $0, section: 0) }
            
            // Perform the batch updates to insert new items
            collectionView.performBatchUpdates({
                self.collectionView.insertItems(at: indexPaths)
            }, completion: nil)
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
        if indexPaths.contains(where: { $0.item >= viewModel.items.count - 5 }) {
            viewModel.loadPokemonData() // Load more data when nearing the end of the list
            }
            
            for indexPath in indexPaths {
                let pokemon = viewModel.items[indexPath.item]
                if viewModel.cache[pokemon.id] == nil {
                    let request = viewModel.networkClient.fetchPokemonImage(for: pokemon.id)
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] image in
                            self?.viewModel.cache[pokemon.id] = image
                        }
                    viewModel.ongoingImageRequests[pokemon.id] = request
                    request.store(in: &viewModel.cancellables)
                }
            }
        }

        func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
            for indexPath in indexPaths {
                let pokemon = viewModel.items[indexPath.item]
                if let request = viewModel.ongoingImageRequests[pokemon.id] {
                    request.cancel() // Cancel the ongoing request
                    viewModel.ongoingImageRequests.removeValue(forKey: pokemon.id) // Remove from tracking dictionary
                }
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PokemonCollectionViewCell.reuseIdentifier, for: indexPath) as? PokemonCollectionViewCell {
            
            let pokemon = viewModel.items[indexPath.row]
            print(pokemon, pokemon.id)
            cell.configure(with: pokemon, image: nil)
            
            if let cachedImage = viewModel.cache[pokemon.id] {
                cell.configure(with: pokemon, image: cachedImage)
            } else {
                viewModel.networkClient.fetchPokemonImage(for: pokemon.id)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] image in
                        if let self {
                            self.viewModel.cache[pokemon.id] = image
                            cell.configure(with: pokemon, image: image)
                        }
                    }
                    .store(in: &viewModel.cancellables)
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    // Make sure this method is part of the UICollectionViewDelegateFlowLayout protocol
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // Calculate the available width by subtracting section insets and interitem spacing
            let padding: CGFloat = 10 + 10 + 10 // left inset + right inset + interitem spacing
            let availableWidth = collectionView.frame.width - padding
            let itemWidth = availableWidth / 2 // Two columns

            return CGSize(width: itemWidth, height: itemWidth)
        }
}
