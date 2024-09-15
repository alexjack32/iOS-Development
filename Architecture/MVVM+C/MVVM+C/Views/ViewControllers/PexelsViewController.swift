//
//  PexelsViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import UIKit
import Combine

class PexelsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    private var viewModel: PexelsViewModel!
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, PexelsMediaItem>!
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the ViewModel
        viewModel = PexelsViewModel()
        
        setupCollectionView()
        setupDataSource()
        setupBindings()
        
        viewModel.fetchMedia() // Fetch initial media data
    }
    
    private func setupCollectionView() {
        let layout = CenteredCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(PexelsCollectionViewCell.self, forCellWithReuseIdentifier: "PexelsCell")
        collectionView.isPrefetchingEnabled = true
        collectionView.isPagingEnabled = false // Disable default paging to handle it manually
        collectionView.decelerationRate = .fast // Fast deceleration for smoother snapping
        view.addSubview(collectionView)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PexelsMediaItem>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, mediaItem: PexelsMediaItem) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PexelsCell", for: indexPath) as! PexelsCollectionViewCell
            
            switch mediaItem {
            case .photo(let photo):
                cell.configure(with: photo)
            case .video(let video):
                cell.configure(with: video)
            }
            
            return cell
        }
    }
    
    private func setupBindings() {
        viewModel.mediaItemsSubject
            .receive(on: RunLoop.main)
            .sink { [weak self] mediaItems in
                self?.applySnapshot(mediaItems: mediaItems)
            }
            .store(in: &cancellables)
    }
    
    private func applySnapshot(mediaItems: [PexelsMediaItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PexelsMediaItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(mediaItems, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - UICollectionViewDataSourcePrefetching
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let maxIndex = indexPaths.map({ $0.row }).max() else { return }
        
        // Prefetch more data when the user is near the end of the list
        if maxIndex >= viewModel.mediaItems.count - 2 {
            viewModel.fetchMoreMedia()
        }
    }
}

extension PexelsViewController {
    enum Section: Hashable {
        case main
    }
}

extension PexelsViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let itemHeight = layout.itemSize.height
        let proposedContentOffset = targetContentOffset.pointee
        let proposedPage = round(proposedContentOffset.y / itemHeight)
        
        // Calculate the new target content offset to snap to the nearest cell
        targetContentOffset.pointee = CGPoint(x: proposedContentOffset.x, y: proposedPage * itemHeight)
    }
}

class CenteredCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }

        let collectionViewSize = collectionView.bounds.size
        let proposedContentOffsetCenterY = proposedContentOffset.y + collectionViewSize.height / 2

        if let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds) {
            var closestAttribute: UICollectionViewLayoutAttributes?
            for attributes in layoutAttributes {
                if closestAttribute == nil || abs(attributes.center.y - proposedContentOffsetCenterY) < abs(closestAttribute!.center.y - proposedContentOffsetCenterY) {
                    closestAttribute = attributes
                }
            }
            return CGPoint(x: proposedContentOffset.x, y: closestAttribute!.center.y - collectionViewSize.height / 2)
        }
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
