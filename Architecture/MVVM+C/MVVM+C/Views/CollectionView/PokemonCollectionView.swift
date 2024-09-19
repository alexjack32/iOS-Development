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
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
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
                print("Batch updates finished successfully.")
            } else {
                print("Batch updates failed.")
            }
            completion?(finished)
        }
    }
}
