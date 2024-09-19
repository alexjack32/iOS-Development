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
        let layout = CenteredCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.minimumLineSpacing = 0
        
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
                let player = self.viewModel.player(for: video)
                cell.configure(with: player)
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
        
        // The ViewModel ensures media items are unique and stable
        snapshot.appendItems(mediaItems)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // Pause all videos when scrolling to avoid multiple videos playing simultaneously
    func pauseVideosInInvisibleCells() {
        viewModel.pauseAllVideos()
    }
    
    // Ensure that all videos are paused when leaving the screen
    func pauseAllVideos() {
        viewModel.pauseAllVideos()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Pause videos during scrolling
        pauseVideosInInvisibleCells()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Pause videos when scrolling ends
        pauseVideosInInvisibleCells()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // Pause videos if dragging stops without deceleration
            pauseVideosInInvisibleCells()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseAllVideos()
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
                                           collectionViewSize.height / 2

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
