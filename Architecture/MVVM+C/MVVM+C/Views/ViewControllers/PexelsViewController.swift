//
//  PexelsViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import UIKit
//
//class PexelsViewController: UIViewController {
//    private var collectionView: UICollectionView!
//    private var dataSource: UICollectionViewDiffableDataSource<Int, MediaType>!
//    private var viewModel = PexelsViewModel()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupCollectionView()
//        setupDataSource()
//        setupBindings()
//        
//        print("HI:)")
//
//        viewModel.fetchMedia(query: "nature")
//    }
//
//    private func setupCollectionView() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 10
//        layout.minimumInteritemSpacing = 10
//
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
//        collectionView.register(PexelsPhotoCollectionViewCell.self, forCellWithReuseIdentifier: PexelsPhotoCollectionViewCell.reuseIdentifier)
//        collectionView.register(PexelsVideoCollectionViewCell.self, forCellWithReuseIdentifier: PexelsVideoCollectionViewCell.reuseIdentifier)
//        collectionView.delegate = self
//        view.addSubview(collectionView)
//    }
//
//    private func setupDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<Int, MediaType>(collectionView: collectionView) { (collectionView, indexPath, mediaType) -> UICollectionViewCell? in
//            switch mediaType {
//            case .photo(let photo):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PexelsPhotoCollectionViewCell.reuseIdentifier, for: indexPath) as! PexelsPhotoCollectionViewCell
//                cell.configure(with: photo)
//                return cell
//            case .video(let video):
//                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PexelsVideoCollectionViewCell.reuseIdentifier, for: indexPath) as! PexelsVideoCollectionViewCell
//                cell.configure(with: video)
//                return cell
//            }
//        }
//    }
//
//    private func setupBindings() {
//        viewModel.$mediaItems.sink { [weak self] mediaItems in
//            self?.applySnapshot(mediaItems: mediaItems)
//        }.store(in: &viewModel.cancellables)
//    }
//
//    private func applySnapshot(mediaItems: [MediaType]) {
//        var snapshot = NSDiffableDataSourceSnapshot<Int, MediaType>()
//        snapshot.appendSections([0])
//        snapshot.appendItems(mediaItems)
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
//}
//
//extension PexelsViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.bounds.width, height: 300)
//    }
//}
