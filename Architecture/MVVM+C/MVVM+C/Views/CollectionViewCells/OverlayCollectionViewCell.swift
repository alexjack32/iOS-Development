//
//  OverlayCollectionViewCell.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 11/1/24.
//

import UIKit


class OverlayCollectionViewCell: UICollectionViewCell {
    // MARK: Proerties
    static let reuseIdentifier: String = "OverlayCollectionViewCell"
    
    var overlayData: OverlayData? {
        didSet {
            setNeedsLayout()
        }
    }
  
    var arrowView: OverlayArrowView?
    
    var anchorDirection: OverlayArrowDirection?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .green
        
        return imageView
    }()
    
    var button: UIButton?
    
    var overlayView: UIView?
    
//    MARK: Overrides functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 662),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalTo: widthAnchor),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        overlayView?.removeFromSuperview()
        arrowView?.removeFromSuperview()
        button?.removeFromSuperview()
        button = nil
        overlayView = nil
        arrowView = nil
        overlayData = nil
        anchorDirection = nil
    }
    
//    MARK: Functions: (@objc, fileprivate, private etc.)
    func configureCell(data: OverlayData) {
        overlayData = data
        imageView.layoutIfNeeded()
        setupButtonAndArrow(with: data)
    }
    
    fileprivate func positionArrowAndOverlayViews() {
        
    }
    
    fileprivate func setupArrowAndOverlayViews(arrowDirection: OverlayArrowDirection) {
        // Set up arrow
        
        print(arrowDirection)
        arrowView = OverlayArrowView(arrowDirection: arrowDirection)
        if let arrowView,
        let button {
            arrowView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(arrowView)
            arrowView.createArrow()
            
            switch arrowDirection {
            case .top, .topLeft, .topRight:
            NSLayoutConstraint.activate([
                    arrowView.topAnchor.constraint(equalTo: button.bottomAnchor),
                    arrowView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                    arrowView.widthAnchor.constraint(equalToConstant: 8),
                    arrowView.heightAnchor.constraint(equalToConstant: 8)
                ])
            case .bottom , .bottomLeft, .bottomRight:
                NSLayoutConstraint.activate([
                    arrowView.bottomAnchor.constraint(equalTo: button.topAnchor),
                    arrowView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                    arrowView.widthAnchor.constraint(equalToConstant: 8),
                    arrowView.heightAnchor.constraint(equalToConstant: 8)
                ])
            case .left:
                NSLayoutConstraint.activate([
                    arrowView.leadingAnchor.constraint(equalTo: button.trailingAnchor),
                    arrowView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                    arrowView.widthAnchor.constraint(equalToConstant: 8),
                    arrowView.heightAnchor.constraint(equalToConstant: 8)
                ])
            case .right:
                NSLayoutConstraint.activate([
                    arrowView.trailingAnchor.constraint(equalTo: button.leadingAnchor),
                    arrowView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                    arrowView.widthAnchor.constraint(equalToConstant: 8),
                    arrowView.heightAnchor.constraint(equalToConstant: 8)
                ])
            }
            arrowView.setNeedsLayout()
        }
        
        // Set up overlay view
        overlayView = UIView()
        if let overlayView ,
        let arrowView {
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            overlayView.backgroundColor = .black
            overlayView.layer.cornerRadius = 10
            overlayView.clipsToBounds = true
            addSubview(overlayView)
            switch arrowDirection {
            case .top:
                NSLayoutConstraint.activate([
                    overlayView.topAnchor.constraint(equalTo: arrowView.bottomAnchor),
                    overlayView.centerXAnchor.constraint(equalTo: arrowView.centerXAnchor),
                    overlayView.widthAnchor.constraint(equalToConstant: 150),
                    overlayView.heightAnchor.constraint(equalToConstant: 50)
                ])
            case .topLeft:
                NSLayoutConstraint.activate([
                    overlayView.topAnchor.constraint(equalTo: arrowView.bottomAnchor),
                    overlayView.leadingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -16),
                    overlayView.widthAnchor.constraint(equalToConstant: 150),
                    overlayView.heightAnchor.constraint(equalToConstant: 50)
                ])
            case .topRight:
                NSLayoutConstraint.activate([
                    overlayView.topAnchor.constraint(equalTo: arrowView.bottomAnchor),
                    overlayView.trailingAnchor.constraint(equalTo: arrowView.trailingAnchor, constant: 16),
                    overlayView.widthAnchor.constraint(equalToConstant: 150),
                    overlayView.heightAnchor.constraint(equalToConstant: 50)
                ])
            case .bottom:
                NSLayoutConstraint.activate([
                    overlayView.bottomAnchor.constraint(equalTo: arrowView.topAnchor),
                    overlayView.centerXAnchor.constraint(equalTo: arrowView.centerXAnchor),
                    overlayView.widthAnchor.constraint(equalToConstant: 150),
                    overlayView.heightAnchor.constraint(equalToConstant: 50)
                ])
            case .bottomLeft:
                NSLayoutConstraint.activate([
                    overlayView.bottomAnchor.constraint(equalTo: arrowView.topAnchor),
                    overlayView.leadingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -16),
                    overlayView.widthAnchor.constraint(equalToConstant: 150),
                    overlayView.heightAnchor.constraint(equalToConstant: 50)
                ])
            case .bottomRight:
                NSLayoutConstraint.activate([
                    overlayView.bottomAnchor.constraint(equalTo: arrowView.topAnchor),
                    overlayView.trailingAnchor.constraint(equalTo: arrowView.trailingAnchor, constant: 16),
                    overlayView.widthAnchor.constraint(equalToConstant: 150),
                    overlayView.heightAnchor.constraint(equalToConstant: 50)
                ])
            case .left:
                NSLayoutConstraint.activate([
                    overlayView.leadingAnchor.constraint(equalTo: arrowView.trailingAnchor),
                    overlayView.centerYAnchor.constraint(equalTo: arrowView.centerYAnchor),
                    overlayView.widthAnchor.constraint(equalToConstant: 150),
                    overlayView.heightAnchor.constraint(equalToConstant: 50)
                ])
            case .right:
                NSLayoutConstraint.activate([
                    overlayView.trailingAnchor.constraint(equalTo: arrowView.leadingAnchor),
                    overlayView.centerYAnchor.constraint(equalTo: arrowView.centerYAnchor),
                    overlayView.widthAnchor.constraint(equalToConstant: 150),
                    overlayView.heightAnchor.constraint(equalToConstant: 50)
                ])
            }
            overlayView.setNeedsLayout()
        }
    }
    
    private func setupButtonAndArrow(with data: OverlayData) {
        // Calculate the position in the image based on x, y percentage coordinates
        guard let x = Double(data.coords.x), let y = Double(data.coords.y) else { return }
        
        let imageSize = imageView.bounds.size
        let xPoint = x * imageSize.width
        let yPoint = y * imageSize.height
        
        // Configure and add button
        var configuration = UIButton.Configuration.filled()
        configuration.image = UIImage(systemName: "circle.fill")?.withRenderingMode(.alwaysTemplate)
        configuration.cornerStyle = .capsule
        button = UIButton(configuration: configuration)
        
        if let button {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.configurationUpdateHandler = { button in
                var newConfiguration = button.configuration
                switch button.state {
                case .normal:
                    newConfiguration?.baseBackgroundColor = .black.withAlphaComponent(0.7)
                    newConfiguration?.baseForegroundColor = .gray
                case .selected:
                    newConfiguration?.baseBackgroundColor = .black
                    newConfiguration?.baseForegroundColor = .white
                default:
                    newConfiguration?.baseBackgroundColor = .black.withAlphaComponent(0.7)
                    newConfiguration?.baseForegroundColor = .gray
                }
                button.configuration = newConfiguration
            }
            
            addSubview(button)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 32),
                button.heightAnchor.constraint(equalToConstant: 32),
                button.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: xPoint),
                button.topAnchor.constraint(equalTo: imageView.topAnchor, constant: yPoint)
            ])
            setNeedsLayout()
            

            setupArrowAndOverlayViews(
                arrowDirection: getArrowDirection(x: xPoint, y: yPoint, imageSize: imageSize)
            )
        }
    }
    
    func getArrowDirection(x: Double, y: Double, imageSize: CGSize) -> OverlayArrowDirection {
        // Create 3x3 map to get proper anchor position
        let oneThirdWidth = imageSize.width / 3.0
        let twoThirdsWidth = oneThirdWidth * 2.0
        let oneThirdHeight = imageSize.height / 3.0
        let twoThirdsHeight = oneThirdHeight * 2.0
        
        // Switch based on (x, y) values to place buttons in proper areas
        switch (x, y) {
        case (0 ... oneThirdWidth, 0 ... oneThirdHeight):
            return .topLeft // (0, 0)
        case (0 ... oneThirdWidth, 0 ... twoThirdsHeight):
            return .left // (0, 1)
        case (0 ... oneThirdWidth, twoThirdsHeight ... imageSize.height):
            return .bottomLeft // (0, 2)
        case (oneThirdWidth ... twoThirdsWidth, 0 ... oneThirdHeight):
            return .top // (1, 0)
        case (oneThirdWidth ... twoThirdsWidth, oneThirdWidth ... oneThirdHeight):
            return .bottom // (1, 1)
        case (oneThirdWidth ... twoThirdsWidth, twoThirdsHeight ... imageSize.height):
            return .bottom // (1, 2)
        case (twoThirdsWidth ... imageSize.width, 0 ... oneThirdHeight):
            return .topRight //(2, 0)
        case (twoThirdsWidth ... imageSize.width, oneThirdHeight ... twoThirdsHeight):
            return .right // (2, 1)
        case (twoThirdsWidth ... imageSize.width, twoThirdsHeight ... imageSize.height):
            return .bottomRight // (2, 2)
            
        default: return .top
        }
    }
    
    @objc func tappedButton() {
        if let button {
            button.isSelected.toggle()
        }
    }
}
