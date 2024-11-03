//
//  OverlayViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 10/21/24.
//

import Combine
import UIKit

enum ArrowPosition {
    case top
    case left
    case right
    case bottom
    case bottomRight
    case bottomLeft
    case topLeft
    case topRight
}

class OverlayViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, OverlayData>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, OverlayData>
    
    enum Section {
        case main
    }
    var cancellable = Set<AnyCancellable>()
    var viewModel: OverlayViewModel = {
        let viewModel = OverlayViewModel()
        return viewModel
    }()
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.showsVerticalScrollIndicator = false
        view.isPagingEnabled = true
        
        view.register(
            OverlayCollectionViewCell.self,
            forCellWithReuseIdentifier: OverlayCollectionViewCell.reuseIdentifier
        )
        view.register(
            ErrorCollectionViewCell.self,
            forCellWithReuseIdentifier: ErrorCollectionViewCell.reuseIdentifier
            )

        return view
    }()
    
    lazy var dataSource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OverlayCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? OverlayCollectionViewCell else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ErrorCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as? ErrorCollectionViewCell
                return cell 
            }
            
            DispatchQueue.main.async {
                cell.configureCell(data: item)
            }
            
            return cell
        }
        return dataSource
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        bindViewModel()
        viewModel.loadItems()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            if let self {
                collectionView.invalidateIntrinsicContentSize()
            }
        }, completion: nil)
    }
    func bindViewModel() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {[weak self] completion in
                if let self {
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }, receiveValue: { [weak self] result in
                if let self {
                    applySnapshot(items: result)
                }
            })
            .store(in: &cancellable)
    }
    
    func applySnapshot(items: [OverlayData]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot,animatingDifferences: true)
    }
}

extension OverlayViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Determine the shorter side of the screen to create a square
        let sideLength = min(collectionView.bounds.width, collectionView.bounds.height)
        return CGSize(width: sideLength, height: sideLength)
    }
}
