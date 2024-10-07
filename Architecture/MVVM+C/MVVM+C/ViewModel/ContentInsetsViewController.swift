//
//  ContentInsetsViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 10/5/24.
//

import UIKit

import UIKit

class LargerTouchAreaSlider: UISlider {
    
    // Define the touch area insets (negative values to expand the area)
    var touchAreaInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    
    // Override layoutSubviews to add visual debugging
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Remove any existing layers that may stack up from previous calls
        self.layer.sublayers?.removeAll { $0 is CAShapeLayer }
        
        // Add a border to the slider to visualize its original size
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
        
        // Create a layer to visualize the expanded touch area
        let touchableAreaLayer = CAShapeLayer()
        let touchableAreaFrame = bounds.inset(by: touchAreaInsets)
        touchableAreaLayer.frame = touchableAreaFrame
        touchableAreaLayer.borderColor = UIColor.green.cgColor
        touchableAreaLayer.borderWidth = 1
        touchableAreaLayer.backgroundColor = UIColor.clear.cgColor
        
        // Add the touchable area layer for debugging
        self.layer.addSublayer(touchableAreaLayer)
    }
    
    // Override point(inside:with:) to adjust the touch area
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerBounds = bounds.inset(by: touchAreaInsets)
        return largerBounds.contains(point)
    }
    
    // Override hitTest to allow touches in expanded area to register with the control
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let largerBounds = bounds.inset(by: touchAreaInsets)
        return largerBounds.contains(point) ? self : nil
    }
    
    // Override touchesBegan to recognize taps anywhere along the track
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        
        // Get the location of the touch in the slider's coordinate space
        let touchLocation = touch.location(in: self)
        
        // Check if the user tapped directly on the thumb, allow the default drag behavior
        let thumbFrame = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
        if thumbFrame.contains(touchLocation) {
            // Let the default dragging behavior proceed
            return
        }
        
        // If the tap is not directly on the thumb, calculate the equivalent slider value
        let percentage = touchLocation.x / bounds.width
        let delta = maximumValue - minimumValue
        let newValue = delta * Float(percentage) + minimumValue
        
        // Set the slider's value to the new value (move the thumb)
        setValue(newValue, animated: true)
        
        // Trigger the value change action
        sendActions(for: .valueChanged)
        
        // Begin tracking for dragging after tapping
        beginTracking(touch, with: event)
    }
    
    // Continue dragging after the initial tap
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        
        // Allow dragging behavior to update the slider value
        continueTracking(touch, with: event)
    }
    
    // End tracking
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        endTracking(touches.first, with: event)
    }
}
class SwitchContainerView: UIView {
    
    var touchAreaInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
    
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(switchControl)
        
        // Center the UISwitch inside the container view
        NSLayoutConstraint.activate([
            switchControl.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            switchControl.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        // Add a border to the container view for visual debugging
        self.layer.borderColor = UIColor.green.cgColor
        self.layer.borderWidth = 1
    }
    
    // Override hitTest to expand the touchable area
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let expandedBounds = bounds.inset(by: touchAreaInsets)
        return expandedBounds.contains(point) ? switchControl : nil
    }
}

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
    
    // Create UISwitch using container view
    let switchContainer: SwitchContainerView = {
        let container = SwitchContainerView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    // Create UISlider using custom class
    let largerTouchSlider: LargerTouchAreaSlider = {
        let slider = LargerTouchAreaSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Content Insets"
        view.backgroundColor = .systemBackground
        
        // Add buttons, switch, and slider to view hierarchy
        view.addSubview(noInsetsButton)
        view.addSubview(insetsButton)
        view.addSubview(switchContainer)
        view.addSubview(largerTouchSlider)
        
        noInsetsButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        insetsButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set up constraints for buttons, switch, and slider
        NSLayoutConstraint.activate([
            noInsetsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            noInsetsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            noInsetsButton.widthAnchor.constraint(equalToConstant: 50),
            noInsetsButton.heightAnchor.constraint(equalToConstant: 50),
            
            insetsButton.topAnchor.constraint(equalTo: noInsetsButton.bottomAnchor, constant: 20),
            insetsButton.leadingAnchor.constraint(equalTo: noInsetsButton.leadingAnchor),
            insetsButton.widthAnchor.constraint(equalTo: noInsetsButton.widthAnchor),
            insetsButton.heightAnchor.constraint(equalTo: noInsetsButton.heightAnchor),
            
            // Set up custom switch container with larger touch area
            switchContainer.topAnchor.constraint(equalTo: insetsButton.bottomAnchor, constant: 30),
            switchContainer.leadingAnchor.constraint(equalTo: noInsetsButton.leadingAnchor),
            switchContainer.widthAnchor.constraint(equalToConstant: 100),
            switchContainer.heightAnchor.constraint(equalToConstant: 60),
            
            // Set up custom slider with larger touch area
            largerTouchSlider.topAnchor.constraint(equalTo: switchContainer.bottomAnchor, constant: 30),
            largerTouchSlider.leadingAnchor.constraint(equalTo: noInsetsButton.leadingAnchor),
            largerTouchSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
        ])
    }
    
    @objc func buttonTapped() {
        print("Button tapped")
    }
}
