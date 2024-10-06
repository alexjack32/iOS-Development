//
//  ContentInsetsViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 10/5/24.
//

import UIKit

class LargerTouchAreaButton: UIButton {
    
    // Define the touch area insets (negative values to expand the area)
    var touchAreaInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    
    // Override the layoutSubviews method to add visual debugging
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Remove any existing border layers to avoid stacking borders
        self.layer.sublayers?.removeAll { $0 is CAShapeLayer }
        
        // Add a border directly to the button's layer to show its visual size
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
        
        // Add a green border around the tappable area (touchable area insets)
        let touchableAreaLayer = CAShapeLayer()
        let touchableAreaFrame = bounds.inset(by: touchAreaInsets)
        touchableAreaLayer.frame = touchableAreaFrame
        touchableAreaLayer.borderColor = UIColor.green.cgColor
        touchableAreaLayer.borderWidth = 1
        touchableAreaLayer.backgroundColor = UIColor.clear.cgColor
        
        // Add the touchable area border layer to the button's layer
        self.layer.addSublayer(touchableAreaLayer)
    }

    // Override point(inside:with:) to adjust the touch area and log touches
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerBounds = bounds.inset(by: touchAreaInsets)
        return largerBounds.contains(point)
    }
}

class ContentInsetsViewController: UIViewController {
    
    // Create no insets button
    let noInsetsButton: LargerTouchAreaButton = {
        let button = LargerTouchAreaButton()
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.touchAreaInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return button
    }()
    
    // Create insets button
    let insetsButton: LargerTouchAreaButton = {
        let button = LargerTouchAreaButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Content Insets"
        view.backgroundColor = .systemCyan
        
        // Add buttons to view hierarchy
        view.addSubview(noInsetsButton)
        view.addSubview(insetsButton)
        noInsetsButton.addTarget(self, action: #selector (buttonTapped), for: .touchUpInside)
        insetsButton.addTarget(self, action: #selector (buttonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set up constraints for buttons
        NSLayoutConstraint.activate([
            noInsetsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            noInsetsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            noInsetsButton.widthAnchor.constraint(equalToConstant: 50),
            noInsetsButton.heightAnchor.constraint(equalToConstant: 50),
            
            insetsButton.topAnchor.constraint(equalTo: noInsetsButton.bottomAnchor, constant: 20),
            insetsButton.leadingAnchor.constraint(equalTo: noInsetsButton.leadingAnchor),
            insetsButton.widthAnchor.constraint(equalTo: noInsetsButton.widthAnchor),
            insetsButton.heightAnchor.constraint(equalTo: noInsetsButton.heightAnchor)
        ])
    }
    
    @objc func buttonTapped() {
        print("Button tapped")
    }
}
