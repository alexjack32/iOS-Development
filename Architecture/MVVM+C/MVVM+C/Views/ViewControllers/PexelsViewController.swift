//
//  PexelsViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import UIKit
import Combine

class PexelsViewController: UIViewController, UICollectionViewDelegate {
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, PexelsMediaItem>!
    
    private var viewModel = PexelsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDataSource()
        setupBindings()
        
        viewModel.fetchMedia() // Initial fetch of media items
    }
    
    private func setupCollectionView() {
        let layout = CenteredCollectionViewFlowLayout() // Using your custom layout
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumLineSpacing = 0 // To avoid spacing between items
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(PexelsCollectionViewCell.self, forCellWithReuseIdentifier: "PexelsCell")
        collectionView.isPrefetchingEnabled = true
        collectionView.isPagingEnabled = true
        
        view.addSubview(collectionView)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, PexelsMediaItem>(collectionView: collectionView) { (collectionView, indexPath, mediaItem) -> UICollectionViewCell? in
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
                self?.applySnapshot(with: mediaItems)
            }
            .store(in: &cancellables)
    }

    private func applySnapshot(with mediaItems: [PexelsMediaItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PexelsMediaItem>()
        snapshot.appendSections([.main])
        
        let uniqueItems = Array(Set(mediaItems)) // Remove duplicates if needed
        snapshot.appendItems(uniqueItems)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // Pausing videos in cells that are no longer visible
    func pauseVideosInInvisibleCells() {
        // Get all currently visible cells
        let visibleCells = collectionView.visibleCells as! [PexelsCollectionViewCell]
        
        // Get all index paths of visible items
        let allIndexPaths = collectionView.indexPathsForVisibleItems
        
        // Iterate through all index paths to check if the cell is still visible
        for indexPath in allIndexPaths {
            // Get the cell for the current index path
            if let cell = collectionView.cellForItem(at: indexPath) as? PexelsCollectionViewCell {
                // Check if the cell contains a video
                if case .video(_) = viewModel.mediaItems[indexPath.item] {
                    // If the cell is not visible, pause the video
                    if !visibleCells.contains(cell) {
                        cell.pauseVideo()
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension PexelsViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let maxIndex = indexPaths.map({ $0.row }).max() else { return }
        
        if maxIndex >= viewModel.mediaItems.count - 2 {
            viewModel.fetchMoreMedia()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PexelsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Continuously pause videos as the user scrolls
        pauseVideosInInvisibleCells()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Ensure videos are paused when scrolling stops
        pauseVideosInInvisibleCells()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // If not decelerating, ensure videos are paused when dragging ends
            pauseVideosInInvisibleCells()
        }
    }
}

// MARK: - Section Enum
extension PexelsViewController {
    enum Section: Hashable {
        case main
    }
}

class CenteredCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }

        let collectionViewSize = collectionView.bounds.size
        let proposedContentOffsetCenterY = proposedContentOffset.y + 
                                           collectionViewSize.height /
                                           2

        if let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds) {
            var closestAttribute: UICollectionViewLayoutAttributes?
            for attributes in layoutAttributes {
                if closestAttribute == nil || 
                    abs(attributes.center.y - proposedContentOffsetCenterY) <
                    abs(closestAttribute!.center.y - proposedContentOffsetCenterY) {
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
