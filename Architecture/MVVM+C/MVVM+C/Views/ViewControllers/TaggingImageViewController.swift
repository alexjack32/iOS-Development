//
//  TaggingImageViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 10/21/24.
//

import UIKit

class TaggingImageViewController: UIViewController {
    
    var imageData: ImageData
    
    init(imageData: ImageData) {
        self.imageData = imageData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and display the image view
        let imageView = UIImageView(frame: view.bounds)
        if let image = UIImage(contentsOfFile: imageData.imagePath) {
            imageView.image = image
        }
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Ensure layout is updated before calculating button positions
        view.layoutIfNeeded()
        
        // Add buttons based on the JSON coordinates
        for buttonData in imageData.buttons {
            let button = UIButton(frame: .zero)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .red
            button.layer.cornerRadius = 25
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            self.view.addSubview(button)
            
            if let image = imageView.image {
                // Calculate the displayed size of the image in the UIImageView
                let imageSize = image.size
                let imageViewSize = imageView.bounds.size
                
                let imageAspectRatio = imageSize.width / imageSize.height
                let imageViewAspectRatio = imageViewSize.width / imageViewSize.height
                
                var displayedImageSize: CGSize
                
                if imageAspectRatio > imageViewAspectRatio {
                    // Image is wider than the view
                    displayedImageSize = CGSize(width: imageViewSize.width, height: imageViewSize.width / imageAspectRatio)
                } else {
                    // Image is taller than the view
                    displayedImageSize = CGSize(width: imageViewSize.height * imageAspectRatio, height: imageViewSize.height)
                }
                
                // Calculate the offset from the top and left for centering
                let xOffset = (imageViewSize.width - displayedImageSize.width) / 2
                let yOffset = (imageViewSize.height - displayedImageSize.height) / 2
                
                // Position the buttons using the scaled image size and offset
                NSLayoutConstraint.activate([
                    button.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: xOffset + buttonData.x * displayedImageSize.width),
                    button.topAnchor.constraint(equalTo: imageView.topAnchor, constant: yOffset + buttonData.y * displayedImageSize.height),
                    button.widthAnchor.constraint(equalToConstant: 50),
                    button.heightAnchor.constraint(equalToConstant: 50)
                ])
            }
        }
    }
    
    @objc func buttonTapped(sender: UIButton) {
        print("Button at \(sender.frame.origin) tapped")
    }
}
