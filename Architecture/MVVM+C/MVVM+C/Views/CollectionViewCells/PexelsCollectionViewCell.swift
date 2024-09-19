//
//  PexelsCollectionViewCell.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/15/24.
//

import UIKit
import AVKit

class PexelsCollectionViewCell: UICollectionViewCell {
    private var imageView: UIImageView = UIImageView()
    private var playerLayer: AVPlayerLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cleanupForReuse()
    }
    
    private func setupViews() {
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
    }
    
    func configure(with photo: PexelsPhoto) {
        cleanupForReuse() // Ensure the cell is cleaned up before configuring
        loadImage(for: photo)
    }
    
    func configure(with player: AVPlayer) {
        cleanupForReuse() // Ensure the cell is cleaned up before configuring
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = contentView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let playerLayer = playerLayer {
            contentView.layer.addSublayer(playerLayer)
        }
        
        player.play()
    }
    
    private func cleanupForReuse() {
        imageView.image = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    private func loadImage(for photo: PexelsPhoto) {
        if let url = URL(string: photo.src.original), let cachedImage = MediaCache.shared.cachedImage(for: url as NSURL) {
            imageView.image = cachedImage
        } else if let url = URL(string: photo.src.original) {
            fetchImage(from: url)
        }
    }
    
    private func fetchImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
                MediaCache.shared.cacheImage(image, for: url as NSURL)
            }
        }.resume()
    }
    
    deinit {
        cleanupForReuse()
    }
}
