//
//  CustomCells.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 9/12/24.
//

import UIKit

class PokemonCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "PokeCell"
    let imageView = UIImageView()
    let nameLabel = UILabel()
    let numberLabel = UILabel()
    private var imageViewWidthConstraint: NSLayoutConstraint!
    private var imageViewHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(numberLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFill
        
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 1
        
        numberLabel.textAlignment = .left
        numberLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        numberLabel.textColor = .black
        numberLabel.numberOfLines = 1
        
        // Initial constraints for the image view
            imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 300)
            imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 300)
            
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageViewWidthConstraint,
            imageViewHeightConstraint,
            
            nameLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            nameLabel.heightAnchor.constraint(equalToConstant: 32),

            numberLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            numberLabel.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -8),
            numberLabel.heightAnchor.constraint(equalToConstant: 32)
            
        ])
        print("LayoutSubviews \(self.hashValue) <><")
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        if UIDevice.current.orientation.isPortrait {
            imageViewWidthConstraint.constant = 300
            imageViewHeightConstraint.constant = 300
        } else {
            imageViewWidthConstraint.constant = 500
            imageViewHeightConstraint.constant = 500
        }
        print("Update constraints <><")
    }
        
    private func setupView() {
    }
    
    func configure(with pokemon: Pokemon, image: UIImage?) {
        nameLabel.text = pokemon.name.capitalized
        numberLabel.text = "#\(pokemon.id)"
        imageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        nameLabel.text = nil
        numberLabel.text = nil
    }
    
}
