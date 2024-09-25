//
//  DiffableDataSourceViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/25/24.
//

import UIKit
import Combine

class DiffableDataSourceViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Int, MyCustomModel>!
    private var viewModel: DiffableViewModel!
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = DiffableViewModel()
        
        setupCollectionView()
        setupDataSource()
        bindViewModel()
        
        viewModel.loadData()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size // Set an appropriate item size
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.scrollsToTop = true
        // Register cells for each type
        collectionView.register(CellType1.self, forCellWithReuseIdentifier: "CellType1")
        collectionView.register(CellType2.self, forCellWithReuseIdentifier: "CellType2")
        collectionView.register(CellType3.self, forCellWithReuseIdentifier: "CellType3")
        
        view.addSubview(collectionView)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, MyCustomModel>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .stringItem(let text):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellType1", for: indexPath) as! CellType1
                cell.configure(with: text)
                return cell
                
            case .intItem(let number):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellType2", for: indexPath) as! CellType2
                cell.configure(with: number)
                return cell
                
            case .boolItem(let flag):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellType3", for: indexPath) as! CellType3
                cell.configure(with: flag)
                return cell
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.snapshotSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                print("Received snapshot with \(snapshot.numberOfItems) items")
                self?.dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
//        viewModel.sendSnapshot()
    }
}

class CellType1: UICollectionViewCell {
    func configure(with data: String) {
        self.contentView.backgroundColor = .red
    }
}

class CellType2: UICollectionViewCell {
    func configure(with data: Int) {
        self.contentView.backgroundColor = .green
    }
}

class CellType3: UICollectionViewCell {
    func configure(with data: Bool) {
        self.contentView.backgroundColor = data ? .blue : .yellow
    }
}
