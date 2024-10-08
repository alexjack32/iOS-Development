//
//  PexelsVideoCollectionViewCell.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import DD4Y_UIKit
import UIKit
import AVFoundation

class VideoCollectionViewCell: UICollectionViewCell, BaseSliderDelegate {

    static let reuseIdentifier = "VideoCell"
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerStatusObserver: NSKeyValueObservation?
    private var timeObserverToken: Any?

    // Create the BaseSlider instance
    private let videoSlider = BaseSlider()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPlayerLayer()
        setupSlider()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayerLayer()
        setupSlider()
    }

    // Setup the video player layer
    private func setupPlayerLayer() {
        playerLayer = AVPlayerLayer()                      // Create the AVPlayerLayer
        playerLayer?.videoGravity = .resizeAspectFill      // Set video gravity (fill the view with video)
        contentView.layer.addSublayer(playerLayer!)        // Add the playerLayer to the contentView's layer
    }

    // Setup the slider
    private func setupSlider() {
        contentView.addSubview(videoSlider)
        videoSlider.delegate = self  // Set the delegate to self
        videoSlider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            videoSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            videoSlider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40), // More space at bottom
            videoSlider.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    // Configure the cell with the video URL
    func configure(with videoURL: URL) {
        playerStatusObserver?.invalidate()
        timeObserverToken = nil

        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        playerLayer?.player = player  // Attach the player to the playerLayer

        observePlayerStatus()
        observePlayerTime()
        player?.play()  // Start playing video by default
    }

    // Observe player status and log any errors
    private func observePlayerStatus() {
        playerStatusObserver = player?.observe(\.status, options: [.new, .old], changeHandler: { [weak self] player, _ in
            guard let self = self else { return }

            switch player.status {
            case .readyToPlay:
                print("Player is ready to play")
                self.updateSliderForVideoDuration()
                self.player?.play()  // Start playing if the player is ready
            case .failed:
                print("Player failed to load the video: \(String(describing: player.error?.localizedDescription))")
            case .unknown:
                print("Player status is unknown")
            @unknown default:
                break
            }
        })
    }

    // Observe player time and update slider
    private func observePlayerTime() {
        // Update every second
        let interval = CMTime(seconds: 1.0, preferredTimescale: 1)  // Update at 1-second intervals
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(self.player?.currentItem?.duration ?? CMTime.zero)
            self.videoSlider.value = Float(currentTime / duration)
        }
    }


    // Update the slider's maximum value to match the video's duration
    private func updateSliderForVideoDuration() {
        if let duration = player?.currentItem?.duration {
            let seconds = CMTimeGetSeconds(duration)
            if !seconds.isNaN && seconds > 0 {
                videoSlider.maximumValue = Float(seconds)
            } else {
                videoSlider.maximumValue = 1.0
            }
        }
    }

    // MARK: - BaseSliderDelegate Methods
    
    // Called when the slider value changes (during dragging, no seek)
    func sliderValueDidChange(_ slider: BaseSlider, value: Float) {
        // Just update the UI or preview, but don't seek here to avoid jumps
    }

    // Seek the video when the user releases the slider
    func sliderDidEndSliding(_ slider: BaseSlider) {
        guard let player = player else { return }
        
        // Seek to the new time based on the slider value
        let duration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)
        let newTime = duration * Double(slider.value)
        let seekTime = CMTime(seconds: newTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        player.seek(to: seekTime) { [weak self] finished in
            if finished {
                print("Video seek completed to time: \(newTime) seconds")
                self?.player?.play() // Optionally resume playback after seeking
            }
        }
    }

    // Pause the video when the user starts sliding the slider
    func sliderDidStartSliding(_ slider: BaseSlider) {
        guard let player = player else { return }
        player.pause()  // Pause the video while sliding
        print("Video paused while sliding")
    }

    // Clean up when the cell is reused
    override func prepareForReuse() {
        super.prepareForReuse()
        stopVideo()
        playerLayer?.player = nil // Remove the player from the layer
        player = nil // Clean up the player
        playerStatusObserver?.invalidate() // Remove the observer when the cell is reused
        playerStatusObserver = nil
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }

    // Stop the video and reset to the beginning
    func stopVideo() {
        player?.pause()
        player?.seek(to: .zero)
    }
    
    // Clean up any observers or resources
    deinit {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
        }
        playerStatusObserver?.invalidate()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure the playerLayer is properly sized to fit the contentView
        playerLayer?.frame = contentView.bounds
    }
}
