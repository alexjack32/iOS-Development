//
//  PexelsVideoCollectionViewCell.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//
import UIKit
import AVKit

class PexelsVideoCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PexelsVideoCollectionViewCell"

    private let imageView = UIImageView()
    private let videoView = UIView()
    private var player: AVPlayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(videoView)
        imageView.frame = contentView.bounds
        videoView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        videoView.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with video: VideoDetails) {
        if let image = video.videoPictures.first?.picture,
           let video = video.videoFiles.first?.link {
            loadImage(from: image)
            loadVideo(from: video)
        }
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }

    private func loadVideo(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        DispatchQueue.main.async {
            self.player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = self.videoView.bounds
            self.videoView.layer.addSublayer(playerLayer)
            self.player?.play()
            self.imageView.isHidden = true
            self.videoView.isHidden = false
        }
    }
}
