//
//  OverlayViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 10/21/24.
//

import UIKit

enum ArrowPosition {
    case top
    case left
    case right
    case bottom
    case bottomRight
    case bottomLeft
    case topLeft
    case topRight
}

class OverlayViewController: UIViewController {
    
    private var overlayView: UIView?
    private var arrowView: UIView?
    private let anchorButton = UIButton(type: .system) // Button to anchor the overlay
    private var arrowPosition: ArrowPosition = .right // Default position
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupButton()
        setupOverlay(position: arrowPosition) // Set initial position for overlay and arrow

        // Observe device orientation changes
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    // Setup the anchor button
    private func setupButton() {
        anchorButton.setTitle("Show Overlay", for: .normal)
        anchorButton.translatesAutoresizingMaskIntoConstraints = false
        anchorButton.addTarget(self, action: #selector(toggleOverlay), for: .touchUpInside)
        view.addSubview(anchorButton)
        
        NSLayoutConstraint.activate([
            anchorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            anchorButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Setup the overlay and arrow views with specified position
    private func setupOverlay(position: ArrowPosition) {
        arrowPosition = position
        let overlay = createOverlayView(title: "Sample Title", price: "$8.98")
        overlay.isHidden = true // Hide initially
        view.addSubview(overlay)
        overlayView = overlay

        let arrow = createArrowView(for: position) // Use the position to create correct arrow orientation
        arrow.isHidden = true
        view.addSubview(arrow)
        arrowView = arrow

        positionOverlayAndArrow() // Position overlay and arrow based on specified position
    }

    // Helper method to create the overlay view
    private func createOverlayView(title: String, price: String) -> UIView {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlayView.layer.cornerRadius = 8
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(titleLabel)
        
        // Price Label
        let priceLabel = UILabel()
        priceLabel.text = price
        priceLabel.textColor = .white
        priceLabel.font = UIFont.systemFont(ofSize: 12)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(priceLabel)
        
        // Define constraints for titleLabel and priceLabel to remove ambiguity
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -8),
            priceLabel.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -8)
        ])
        
        return overlayView
    }
    
    // Helper method to create the arrow view
    private func createArrowView(for position: ArrowPosition) -> UIView {
        let arrowView = UIView()
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.backgroundColor = .clear
        
        let arrowLayer = CAShapeLayer()
        let arrowPath = UIBezierPath()
        
        switch position {
        case .top:
            // Arrow pointing up
            arrowPath.move(to: CGPoint(x: 10, y: 0))
            arrowPath.addLine(to: CGPoint(x: 0, y: 10))
            arrowPath.addLine(to: CGPoint(x: 20, y: 10))
            
        case .bottom:
            // Arrow pointing down
            arrowPath.move(to: CGPoint(x: 0, y: 0))
            arrowPath.addLine(to: CGPoint(x: 20, y: 0))
            arrowPath.addLine(to: CGPoint(x: 10, y: 10))
            
        case .left:
            // Arrow pointing left
            arrowPath.move(to: CGPoint(x: 10, y: 10))
            arrowPath.addLine(to: CGPoint(x: 0, y: 0))
            arrowPath.addLine(to: CGPoint(x: 0, y: 20))
            
        case .right:
            // Arrow pointing right
            arrowPath.move(to: CGPoint(x: 0, y: 10))
            arrowPath.addLine(to: CGPoint(x: 10, y: 0))
            arrowPath.addLine(to: CGPoint(x: 10, y: 20))
            
        case .bottomRight:
            // Arrow pointing down-right
            arrowPath.move(to: CGPoint(x: 0, y: 0))
            arrowPath.addLine(to: CGPoint(x: 20, y: 0))
            arrowPath.addLine(to: CGPoint(x: 10, y: 10))
            
            
        case .bottomLeft:
            // Arrow pointing down-left
            arrowPath.move(to: CGPoint(x: 0, y: 0))
            arrowPath.addLine(to: CGPoint(x: 20, y: 0))
            arrowPath.addLine(to: CGPoint(x: 10, y: 10))
            
        case .topLeft:
            // Arrow pointing up-left
            arrowPath.move(to: CGPoint(x: 10, y: 0))
            arrowPath.addLine(to: CGPoint(x: 0, y: 10))
            arrowPath.addLine(to: CGPoint(x: 20, y: 10))

        case .topRight:
            // Arrow pointing up-right
            arrowPath.move(to: CGPoint(x: 0, y: 10))
            arrowPath.addLine(to: CGPoint(x: 20, y: 10))
            arrowPath.addLine(to: CGPoint(x: 10, y: 0))
        }
        
        arrowPath.close()
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.fillColor = UIColor.black.cgColor
        arrowView.layer.addSublayer(arrowLayer)
        
        return arrowView
    }
    
    // Show/hide overlay on button tap
    @objc private func toggleOverlay() {
        let shouldShow = overlayView?.isHidden ?? true
        overlayView?.isHidden = !shouldShow
        arrowView?.isHidden = !shouldShow
        positionOverlayAndArrow() // Reposition overlay and arrow each time it's shown
    }
    
    // Position overlay and arrow relative to the button based on ArrowPosition
    private func positionOverlayAndArrow() {
        guard let overlayView = overlayView, let arrowView = arrowView else { return }
        
        // Remove any previous constraints to avoid conflicts
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.deactivate(overlayView.constraints)
        NSLayoutConstraint.deactivate(arrowView.constraints)
        
        switch arrowPosition {
        case .top:
            NSLayoutConstraint.activate([
                overlayView.topAnchor.constraint(equalTo: anchorButton.bottomAnchor, constant: 10),
                overlayView.centerXAnchor.constraint(equalTo: anchorButton.centerXAnchor),
                overlayView.widthAnchor.constraint(equalToConstant: 150),
                overlayView.heightAnchor.constraint(equalToConstant: 50),
                
                arrowView.bottomAnchor.constraint(equalTo: overlayView.topAnchor),
                arrowView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
                arrowView.widthAnchor.constraint(equalToConstant: 20),
                arrowView.heightAnchor.constraint(equalToConstant: 10)
            ])
            
        case .bottom:
            NSLayoutConstraint.activate([
                overlayView.bottomAnchor.constraint(equalTo: anchorButton.topAnchor, constant: -10),
                overlayView.centerXAnchor.constraint(equalTo: anchorButton.centerXAnchor),
                overlayView.widthAnchor.constraint(equalToConstant: 150),
                overlayView.heightAnchor.constraint(equalToConstant: 50),
                
                arrowView.topAnchor.constraint(equalTo: overlayView.bottomAnchor),
                arrowView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
                arrowView.widthAnchor.constraint(equalToConstant: 20),
                arrowView.heightAnchor.constraint(equalToConstant: 10)
            ])
            
        case .left:
            NSLayoutConstraint.activate([
                overlayView.trailingAnchor.constraint(equalTo: anchorButton.leadingAnchor, constant: -10),
                overlayView.centerYAnchor.constraint(equalTo: anchorButton.centerYAnchor),
                overlayView.widthAnchor.constraint(equalToConstant: 150),
                overlayView.heightAnchor.constraint(equalToConstant: 50),
                
                arrowView.leadingAnchor.constraint(equalTo: overlayView.trailingAnchor),
                arrowView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
                arrowView.widthAnchor.constraint(equalToConstant: 10),
                arrowView.heightAnchor.constraint(equalToConstant: 20)
            ])
            
        case .right:
            NSLayoutConstraint.activate([
                overlayView.leadingAnchor.constraint(equalTo: anchorButton.trailingAnchor, constant: 10),
                overlayView.centerYAnchor.constraint(equalTo: anchorButton.centerYAnchor),
                overlayView.widthAnchor.constraint(equalToConstant: 150),
                overlayView.heightAnchor.constraint(equalToConstant: 50),
                
                arrowView.trailingAnchor.constraint(equalTo: overlayView.leadingAnchor),
                arrowView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
                arrowView.widthAnchor.constraint(equalToConstant: 10),
                arrowView.heightAnchor.constraint(equalToConstant: 20)
            ])
            
        case .bottomRight:
            NSLayoutConstraint.activate([
                overlayView.bottomAnchor.constraint(equalTo: anchorButton.topAnchor, constant: -10),
                overlayView.leadingAnchor.constraint(equalTo: anchorButton.trailingAnchor, constant: -150),
                overlayView.widthAnchor.constraint(equalToConstant: 150),
                overlayView.heightAnchor.constraint(equalToConstant: 50),
                
                arrowView.topAnchor.constraint(equalTo: overlayView.bottomAnchor),
                arrowView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -10),
                arrowView.widthAnchor.constraint(equalToConstant: 20),
                arrowView.heightAnchor.constraint(equalToConstant: 10)
            ])
            
        case .bottomLeft:
            NSLayoutConstraint.activate([
                overlayView.bottomAnchor.constraint(equalTo: anchorButton.topAnchor, constant: -10),
                overlayView.trailingAnchor.constraint(equalTo: anchorButton.leadingAnchor, constant: 150),
                overlayView.widthAnchor.constraint(equalToConstant: 150),
                overlayView.heightAnchor.constraint(equalToConstant: 50),
                
                arrowView.topAnchor.constraint(equalTo: overlayView.bottomAnchor),
                arrowView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 10),
                arrowView.widthAnchor.constraint(equalToConstant: 20),
                arrowView.heightAnchor.constraint(equalToConstant: 10)
            ])
            
        case .topLeft:
            NSLayoutConstraint.activate([
                overlayView.topAnchor.constraint(equalTo: anchorButton.bottomAnchor, constant: 10),
                overlayView.trailingAnchor.constraint(equalTo: anchorButton.leadingAnchor, constant: 150),
                overlayView.widthAnchor.constraint(equalToConstant: 150),
                overlayView.heightAnchor.constraint(equalToConstant: 50),
                
                arrowView.bottomAnchor.constraint(equalTo: overlayView.topAnchor),
                arrowView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 10),
                arrowView.widthAnchor.constraint(equalToConstant: 20),
                arrowView.heightAnchor.constraint(equalToConstant: 10)
            ])
            
        case .topRight:
            NSLayoutConstraint.activate([
                overlayView.topAnchor.constraint(equalTo: anchorButton.bottomAnchor, constant: 10),
                overlayView.leadingAnchor.constraint(equalTo: anchorButton.trailingAnchor, constant: -150),
                overlayView.widthAnchor.constraint(equalToConstant: 150),
                overlayView.heightAnchor.constraint(equalToConstant: 50),
                
                arrowView.bottomAnchor.constraint(equalTo: overlayView.topAnchor),
                arrowView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -10),
                arrowView.widthAnchor.constraint(equalToConstant: 20),
                arrowView.heightAnchor.constraint(equalToConstant: 10)
            ])
        }
    }

    @objc private func handleOrientationChange() {
        positionOverlayAndArrow()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}
