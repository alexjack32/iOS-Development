//
//  OverlayViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 10/21/24.
//

import UIKit

class OverlayViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Step 1: Add image view to the main view
        let imageView = UIImageView(image: UIImage(named: "yourImageName")) // Replace with your image
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        // Image View Constraints
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Step 2: Add an overlay view
        let overlayView = createOverlayView(title: "Sample Title", price: "$8.98")
        imageView.addSubview(overlayView)
        
        // Overlay View Constraints
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 50),
            overlayView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 100),
            overlayView.widthAnchor.constraint(equalToConstant: 150),
            overlayView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // Helper method to create the overlay view
    func createOverlayView(title: String, price: String) -> UIView {
        // Step 3: Create the overlay container
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlayView.layer.cornerRadius = 8
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        // Step 4: Add a title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(titleLabel)
        
        // Step 5: Add a price label
        let priceLabel = UILabel()
        priceLabel.text = price
        priceLabel.textColor = .white
        priceLabel.font = UIFont.systemFont(ofSize: 12)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(priceLabel)
        
        // Title and price label constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -10),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -5)
        ])
        
        // Step 6: Add an arrow
        let arrowView = createArrowView()
        overlayView.addSubview(arrowView)
        
        // Arrow constraints
        NSLayoutConstraint.activate([
            arrowView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            arrowView.topAnchor.constraint(equalTo: overlayView.bottomAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: 20),
            arrowView.heightAnchor.constraint(equalToConstant: 10)
        ])
        
        return overlayView
    }
    
    // Helper method to create the arrow using Core Graphics
    func createArrowView() -> UIView {
        let arrowView = UIView()
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.backgroundColor = .clear
        arrowView.isOpaque = false
        arrowView.layer.cornerRadius = 2
        
        let arrowLayer = CAShapeLayer()
        let arrowPath = UIBezierPath()
        
        // Draw arrow (triangle)
        arrowPath.move(to: CGPoint(x: 0, y: 0))
        arrowPath.addLine(to: CGPoint(x: 20, y: 0))
        arrowPath.addLine(to: CGPoint(x: 10, y: 10))
        arrowPath.close()
        
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.fillColor = UIColor.black.cgColor
        arrowView.layer.addSublayer(arrowLayer)
        
        return arrowView
    }
}
