//
//  ErrorCollectionViewCell.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 11/1/24.
//

import UIKit

class ErrorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier: String = "ErrorCollectionViewCell"
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addSubview(errorLabel)
        NSLayoutConstraint.activate([
            errorLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            errorLabel.heightAnchor.constraint(equalToConstant: 20.0),
            errorLabel.widthAnchor.constraint(equalToConstant: 200.0)
        ])
    }
}
