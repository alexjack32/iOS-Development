//
//  PokemonCollectionView.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import UIKit

class PokemonCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        
        super.init(frame: frame, collectionViewLayout: layout)
        isPagingEnabled = true
        showsVerticalScrollIndicator = false
        register(PokemonCollectionViewCell.self, forCellWithReuseIdentifier: PokemonCollectionViewCell.reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        super.performBatchUpdates(updates) { finished in
            if finished {
                print("Batch updates finsihed successfully.")
            } else {
                print("Batch updates failed.")
            }
            completion?(finished)
        }
    }
}
