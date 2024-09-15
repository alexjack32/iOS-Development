//
//  PexelsCollectionViewCell.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/15/24.
//

import UIKit
import AVKit

class PexelsCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let playerViewController = AVPlayerViewController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        playerViewController.showsPlaybackControls = false
        contentView.addSubview(playerViewController.view)
        NSLayoutConstraint.activate([
            playerViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            playerViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        playerViewController.view.isHidden = true
    }
    
    func configure(with photo: PexelsPhoto) {
        resetCellForReuse()
        imageView.isHidden = false
        playerViewController.view.isHidden = true
        
        if let url = URL(string: photo.src.original) {
            let nsUrl = url as NSURL
            if let cachedImage = MediaCache.shared.cachedImage(for: nsUrl) {
                imageView.image = cachedImage
            } else {
                loadImage(from: url)
            }
        }
    }
    
    func configure(with video: PexelsVideo) {
        resetCellForReuse()
        imageView.isHidden = true
        playerViewController.view.isHidden = false
        
        if let url = URL(string: video.videoFiles.first?.link ?? "") {
            loadVideo(from: url)
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
                MediaCache.shared.cacheImage(image, for: url as NSURL)
            }
        }.resume()
    }
    
    private func loadVideo(from url: URL) {
        let playerItem = AVPlayerItem(url: url)
        playerViewController.player = AVPlayer(playerItem: playerItem)
        playerViewController.player?.play()
    }
    
    private func resetCellForReuse() {
        imageView.image = nil
        playerViewController.player?.pause()
        playerViewController.player = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetCellForReuse()
    }
}
