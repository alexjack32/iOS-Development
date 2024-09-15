//
//  PexelsPhotoCollectionViewCell.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/13/24.
//

import UIKit

class PexelsPhotoCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PexelsPhotoCollectionViewCell"

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.frame = contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with photo: PexelsPhoto) {
        loadImage(from: photo.src.large)
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
}
