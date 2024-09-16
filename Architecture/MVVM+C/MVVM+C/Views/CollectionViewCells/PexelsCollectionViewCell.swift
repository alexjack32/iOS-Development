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
    private var videoPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private let mediaCache = MediaCache.shared
    
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
    
    func configure(with video: PexelsVideo) {
        cleanupForReuse() // Ensure the cell is cleaned up before configuring
        loadVideo(for: video)
    }
    
    // Helper method to clean up the cell before reuse or reconfiguration
    private func cleanupForReuse() {
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        videoPlayer?.pause()
        videoPlayer = nil
        
        imageView.image = nil
    }
    
    // Helper method to load and cache an image
    private func loadImage(for photo: PexelsPhoto) {
        if let cachedImage = mediaCache.cachedImage(for: URL(string: photo.src.original)! as NSURL) {
            imageView.image = cachedImage
        } else {
            fetchImage(from: URL(string: photo.src.original)!)
        }
    }
    
    // Helper method to load and cache a video
    private func loadVideo(for video: PexelsVideo) {
        if let cachedVideo = mediaCache.cachedVideo(for: URL(string: video.videoFiles.first?.link ?? "")! as NSURL) {
            setupVideoPlayer(with: cachedVideo)
        } else {
            fetchVideo(from: URL(string: video.videoFiles.first?.link ?? "")!)
        }
    }
    
    // Helper method to fetch image asynchronously
    private func fetchImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
                self.mediaCache.cacheImage(image, for: url as NSURL)
            }
        }.resume()
    }
    
    // Helper method to fetch video asynchronously
    private func fetchVideo(from url: URL) {
        let playerItem = AVPlayerItem(url: url)
        DispatchQueue.main.async {
            self.setupVideoPlayer(with: playerItem)
            self.mediaCache.cacheVideo(playerItem, for: url as NSURL)
        }
    }
    
    // Helper method to set up the video player
    private func setupVideoPlayer(with playerItem: AVPlayerItem) {
        videoPlayer = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer?.frame = contentView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let playerLayer = playerLayer {
            contentView.layer.addSublayer(playerLayer)
        }
        
        videoPlayer?.play()
    }
    
    func pauseVideo() {
        videoPlayer?.pause()
    }
}
