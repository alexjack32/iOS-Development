//
//  BaseSlider.swift
//  DD4Y+UIKit
//
//  Created by Alexander Jackson on 10/7/24.
//

import UIKit

// MARK: - BaseSliderDelegate Protocol
public protocol BaseSliderDelegate: AnyObject {
    func sliderValueDidChange(_ slider: BaseSlider, value: Float)  // Called during sliding
    func sliderDidStartSliding(_ slider: BaseSlider)               // Called when sliding starts
    func sliderDidEndSliding(_ slider: BaseSlider)                 // Called when sliding ends
}

// MARK: - BaseSlider Class
public class BaseSlider: UISlider {

    public weak var delegate: BaseSliderDelegate?

    // Define the touch area insets (negative values to expand the touch area)
    var touchAreaInsets = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
    
    

    // Override point(inside:with:) to expand the touch area
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let largerBounds = bounds.inset(by: touchAreaInsets)
        return largerBounds.contains(point)
    }

    // Override hitTest to allow touches in the expanded area to register with the control
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let largerBounds = bounds.inset(by: touchAreaInsets)
        return largerBounds.contains(point) ? self : nil
    }

    // Override touchesBegan to instantly jump to the tapped position and handle dragging
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let touch = touches.first else { return }

        // Get the location of the touch in the slider's coordinate space
        let touchLocation = touch.location(in: self)

        // Calculate the percentage of the touch location along the slider's width
        let percentage = touchLocation.x / bounds.width

        // Calculate the new value based on the percentage of the touch location
        let newValue = (maximumValue - minimumValue) * Float(percentage) + minimumValue

        // Set the slider's value to the new value (move the thumb immediately)
        setValue(newValue, animated: true)
        
        sendActions(for: .valueChanged)

        // Notify delegate that the value has changed immediately
        delegate?.sliderValueDidChange(self, value: self.value)

        // Notify the delegate that sliding has started (for pausing video, etc.)
        delegate?.sliderDidStartSliding(self)

        // Now start the default tracking behavior to allow dragging after the tap
        beginTracking(touch, with: event)
    }

    // Override touchesMoved to notify value change while dragging
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        continueTracking(touch, with: event)
        delegate?.sliderValueDidChange(self, value: self.value)
    }

    // Override touchesEnded to notify when sliding ends (resume video)
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        delegate?.sliderDidEndSliding(self)
    }

    // Handle cancellation (e.g., system interruption)
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        delegate?.sliderDidEndSliding(self)
    }
}
