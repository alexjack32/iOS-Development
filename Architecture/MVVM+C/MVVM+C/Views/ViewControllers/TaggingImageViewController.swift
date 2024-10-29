//
//  TaggingImageViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 10/21/24.
//

import UIKit
// Presents Image with Buttons from prevous View controller
class TaggingImageViewController: UIViewController {

    var cropType: CropType
    var imageData: ImageData
    var buttons: [UIButton] = []
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(
        imageData: ImageData,
        cropType: CropType
    ) {
        self.imageData = imageData
        self.cropType = cropType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        
        // Set constraints for imageView
        NSLayoutConstraint.activate([
//            imageView.topAnchor.constraint(equalTo: view.topAnchor),
//            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0)
        ])
        
        // Load the image
        if let image = UIImage(named: imageData.imagePath) {
            imageView.image = image
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let image = imageView.image else { return }
        
        // Now that layout is completed, we can position the buttons
        layoutButtons(for: image)
    }

    // Layout buttons based on the original image and cropping/padding calculations
    func layoutButtons(for image: UIImage) {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        if let originalImage = UIImage(named: imageData.originalImagePath) {
            let imageSize = image.size
            let displaySize = imageView.frame.size
            
            print("Original Image Size: \(imageSize)")
            print("ImageView Size: \(displaySize)")
 
            let padding = getPadding(imageSize: imageSize,
                                     displaySize: displaySize)
            
            for buttonData in imageData.buttons {
                let button = UIButton(frame: .zero)
                button.backgroundColor = .red
                button.layer.cornerRadius = 16
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                view.addSubview(button)
                buttons.append(button)
                let updatedCoordinates = updateCoordinatePositions(
                    cropType: cropType,
                    originalImageSize: originalImage.size,
                    imageSize: imageSize,
                    data: buttonData
                )
               
                setButtonPosition(
                    with: updatedCoordinates.x,
                    y: updatedCoordinates.y,
                    button: button//,
//                    xPadding: padding.xPadding,
//                    yPadding: padding.yPadding
                )
                
                print(buttonData.x, buttonData.y, "button json data (percentage)")
                print("(\(updatedCoordinates.x), \(updatedCoordinates.y)) (x, y)")
                print(imageSize.width / buttonData.x, " original x coordinate")
                print(imageSize.height / buttonData.y, " original y coordinate\n")
            }
        }
    }
    
    func updateCoordinatePositions(
        cropType: CropType,
        originalImageSize: CGSize,
        imageSize: CGSize,
        data: ButtonData
    ) -> (
        x: CGFloat,
        y: CGFloat
    ){
        switch cropType {
        case .none:
            let x = getXCoordinate(with: data.x)
            let y = getYCoordinate(with: data.y)
            return (x, y)
            
        case .top:
            let croppedPoints = originalImageSize.height - imageSize.height
            let crop = topCropRatio(pixels: croppedPoints, from: originalImageSize.height)
            let updatedDataY: CGFloat = data.y - crop
            print(crop, croppedPoints, " crop top difference percentage")
            print(updatedDataY, " updated y coordinate")
            let x = getXCoordinate(with: data.x)
            let y = getYCoordinate(with: updatedDataY) + 60
            return (x, y)
        }
    }
    
    func getPadding(
        imageSize: CGSize,
        displaySize: CGSize
    ) -> (xPadding: CGFloat, yPadding: CGFloat) {
        var ratioImageSize: CGSize = .zero
        
        var xPadding: CGFloat = 0
        var yPadding: CGFloat = 0
        
        let imageAspectRatio = imageSize.width / imageSize.height
        let displayAspectRatio = displaySize.width / displaySize.height
        print(imageAspectRatio, displayAspectRatio," ratios")
        print(imageView.bounds.width, "bounds width")
        
        if imageAspectRatio > displayAspectRatio {
            print("Image is wider than the imageView, so there's vertical padding")
            ratioImageSize = CGSize(width: imageView.bounds.width, height: imageView.bounds.width / imageAspectRatio)
            yPadding = (imageView.bounds.height - ratioImageSize.height) / 2
            print(ratioImageSize, yPadding, " displayImageSize, yPadding")
        } else {
            print("Image is taller than the imageView, so there's horizontal padding")
            ratioImageSize = CGSize(width: imageView.bounds.height * imageAspectRatio, height: imageView.bounds.height)
            xPadding = (imageView.bounds.width - ratioImageSize.width) / 2
            print(ratioImageSize, xPadding, " displayImageSize, xPadding")
        }
        
        return (xPadding, yPadding)
    }
    
    func topCropRatio(pixels removed: Double, from imageSize: Double) -> Double {
        return removed / imageSize
    }
    
    func getXCoordinate(with x: Double) -> Double {
        return x * Double(imageView.frame.size.width)
    }
    
    func getYCoordinate(with y: Double) -> Double {
        return y * Double(imageView.frame.size.height)
    }
    
    func setButtonPosition(with x: Double, y: Double, button: UIButton, size: CGFloat = 32.0, xPadding: CGFloat = 0.0, yPadding: CGFloat = 0.0) {
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: x - xPadding),
            button.topAnchor.constraint(equalTo: imageView.topAnchor, constant: y + yPadding),
            button.widthAnchor.constraint(equalToConstant: size),
            button.heightAnchor.constraint(equalToConstant: size)
        ])
    }

    // Reposition button based on cropping, aspect ratio, and padding (450px hardcoded crop from top)
    func repositionButton(originalX: CGFloat, originalY: CGFloat, originalImageSize: CGSize, imageViewSize: CGSize, cropType: CropType) -> CGPoint {
        
        // Step 1: Normalize the coordinates based on the original image size (X and Y are percentage-based)
        let normalizedX = originalX
        let normalizedY = originalY
        
        print("Normalized X: \(normalizedX), Normalized Y: \(normalizedY)")
        
        // Step 2: Calculate aspect ratios
        let originalAspectRatio = originalImageSize.width / originalImageSize.height
        let imageViewAspectRatio = imageViewSize.width / imageViewSize.height

        print("Original Aspect Ratio: \(originalAspectRatio), ImageView Aspect Ratio: \(imageViewAspectRatio)")

        var displayedImageSize = imageViewSize
        var xPadding: CGFloat = 0
        var yPadding: CGFloat = 0

        // Step 3: Handle scaling and padding (Aspect Fit)
        if originalAspectRatio > imageViewAspectRatio {
            // Image has top/bottom padding (scaled to fit horizontally)
            displayedImageSize.width = imageViewSize.width
            displayedImageSize.height = imageViewSize.width / originalAspectRatio
            yPadding = (imageViewSize.height - displayedImageSize.height)
            print("Image has top/bottom padding. Displayed Image Size: \(displayedImageSize), Y Padding: \(yPadding)")
        } else {
            // Image has left/right padding (scaled to fit vertically)
            displayedImageSize.height = imageViewSize.height
            displayedImageSize.width = imageViewSize.height * originalAspectRatio
            xPadding = (imageViewSize.width - displayedImageSize.width)
            print("Image has left/right padding. Displayed Image Size: \(displayedImageSize), X Padding: \(xPadding)")
        }

        // Step 4: Hardcoded crop amount (450px from the top)
        let croppedAmountY: CGFloat = 450
        
        let adjustedX = normalizedX * originalImageSize.width
        let adjustedY = (normalizedY * originalImageSize.height - croppedAmountY) / (originalImageSize.height - croppedAmountY)

        print("Initial Adjusted X (using original image): \(adjustedX), Initial Adjusted Y: \(adjustedY)")

        // Step 5: Adjust final position based on displayed size and padding
        let finalX = (adjustedX / originalImageSize.width) * displayedImageSize.width + xPadding
        let finalY = (adjustedY / originalImageSize.height) * displayedImageSize.height + yPadding

        // Debugging: Final position including padding
        print("Final Button Position - X: \(finalX), Y: \(finalY)")

        // Return the calculated position with padding adjustments
        return CGPoint(x: finalX, y: finalY)
    }

    // Button tap handler
    @objc func buttonTapped(sender: UIButton) {
        print("Button tapped at \(sender.frame.origin)")
    }
}

// Enum for different crop types
enum CropType {
    case none
//    case center  //all sides
//    case left
//    case right
    case top
//    case topLeft
//    case topRight
//    case bottom
//    case bottomRight
//    case bottomLeft
}
