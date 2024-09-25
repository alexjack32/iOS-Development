//
//  PexelsVideoCollectionViewCell.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import UIKit
import AVFoundation

class VideoCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "VideoCell"
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerStatusObserver: NSKeyValueObservation?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayerLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayerLayer()
    }
    
    private func setupPlayerLayer() {
        playerLayer = AVPlayerLayer()
        playerLayer?.videoGravity = .resizeAspectFill
        contentView.layer.addSublayer(playerLayer!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds
    }

    // Configure the cell with the video URL
    func configure(with videoURL: URL) {
        // Clean up previous player if any
        playerStatusObserver?.invalidate()

        // Create a new AVPlayerItem for each video playback
        let playerItem = AVPlayerItem(url: videoURL)

        // Initialize AVPlayer with the new AVPlayerItem
        player = AVPlayer(playerItem: playerItem)

        // Attach the player to the playerLayer
        playerLayer?.player = player
        
        print("Setting up AVPlayer for video URL: \(videoURL)")

        // Start observing player status
        observePlayerStatus()

        // Start playing the video
        player?.play()
    }

    // Observe the player's status
    private func observePlayerStatus() {
        playerStatusObserver = player?.observe(\.status, options: [.new, .old], changeHandler: { [weak self] player, change in
            guard self != nil else { return }
            
            switch player.status {
            case .readyToPlay:
                print("Player is ready to play.")
                player.play() // Start playing if ready
            case .failed:
                print("Player failed to load the video: \(String(describing: player.error?.localizedDescription))")
            case .unknown:
                print("Player status is unknown.")
            @unknown default:
                break
            }
        })
    }

    // Clean up when the cell is reused
    override func prepareForReuse() {
        super.prepareForReuse()
        stopVideo()
        playerLayer?.player = nil // Remove the player from the layer
        player = nil // Clean up the player
        playerStatusObserver?.invalidate() // Remove the observer when the cell is reused
        playerStatusObserver = nil
    }

    func stopVideo() {
        player?.pause()
        player?.seek(to: .zero)
    }
}
