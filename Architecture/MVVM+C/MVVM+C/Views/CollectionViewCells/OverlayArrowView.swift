//
//  OverlayArrowView.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 11/2/24.
//

import UIKit

enum OverlayArrowDirection {
    case top
    case topLeft
    case topRight
    case bottom
    case bottomLeft
    case bottomRight
    case left
    case right
}

class OverlayArrowView: UIView {
    var arrowColor: UIColor
    var arrowDirection: OverlayArrowDirection
    var arrowLayer: CAShapeLayer
    var arrowPath: UIBezierPath
    
    init(arrowColor: UIColor = .black,
         arrowDirection: OverlayArrowDirection = .top,
         arrowLayer: CAShapeLayer = CAShapeLayer(),
         arrowPath: UIBezierPath = UIBezierPath()
    ) {
        self.arrowColor = arrowColor
        self.arrowDirection = arrowDirection
        self.arrowLayer = arrowLayer
        self.arrowPath = arrowPath
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createArrow() {
           translatesAutoresizingMaskIntoConstraints = false
           backgroundColor = .clear
           
           // Clear any previous path
           arrowPath.removeAllPoints()
           
           // Calculate midpoints and set up dynamic arrow points
           let midX = bounds.width / 2
           let midY = bounds.height / 2
           let arrowHeight: CGFloat = 8
           let arrowWidth: CGFloat = 8
           
           switch arrowDirection {
           case .top, .topLeft, .topRight:
               // Arrow pointing up and centered horizontally
               arrowPath.move(to: CGPoint(x: midX - arrowWidth / 2, y: arrowHeight))
               arrowPath.addLine(to: CGPoint(x: midX, y: 0))
               arrowPath.addLine(to: CGPoint(x: midX + arrowWidth / 2, y: arrowHeight))
           
           case .bottom, .bottomLeft, .bottomRight:
               // Arrow pointing down and centered horizontally
               arrowPath.move(to: CGPoint(x: midX - arrowWidth / 2, y: bounds.height - arrowHeight))
               arrowPath.addLine(to: CGPoint(x: midX, y: bounds.height))
               arrowPath.addLine(to: CGPoint(x: midX + arrowWidth / 2, y: bounds.height - arrowHeight))
           
           case .left:
               // Arrow pointing left and centered vertically
               arrowPath.move(to: CGPoint(x: arrowHeight, y: midY - arrowWidth / 2))
               arrowPath.addLine(to: CGPoint(x: 0, y: midY))
               arrowPath.addLine(to: CGPoint(x: arrowHeight, y: midY + arrowWidth / 2))
           
           case .right:
               // Arrow pointing right and centered vertically
               arrowPath.move(to: CGPoint(x: bounds.width - arrowHeight, y: midY - arrowWidth / 2))
               arrowPath.addLine(to: CGPoint(x: bounds.width, y: midY))
               arrowPath.addLine(to: CGPoint(x: bounds.width - arrowHeight, y: midY + arrowWidth / 2))
           
//           case .topLeft:
//               // Arrow pointing to the top-left
//               arrowPath.move(to: CGPoint(x: arrowWidth, y: arrowHeight))
//               arrowPath.addLine(to: CGPoint(x: 0, y: 0))
//               arrowPath.addLine(to: CGPoint(x: arrowWidth, y: 0))
//           
//           case .topRight:
//               // Arrow pointing to the top-right
//               arrowPath.move(to: CGPoint(x: bounds.width - arrowWidth, y: arrowHeight))
//               arrowPath.addLine(to: CGPoint(x: bounds.width, y: 0))
//               arrowPath.addLine(to: CGPoint(x: bounds.width, y: arrowHeight))
//           
//           case .bottomLeft:
//               // Arrow pointing to the bottom-left
//               arrowPath.move(to: CGPoint(x: arrowWidth, y: bounds.height - arrowHeight))
//               arrowPath.addLine(to: CGPoint(x: 0, y: bounds.height))
//               arrowPath.addLine(to: CGPoint(x: arrowWidth, y: bounds.height))
//           
//           case .bottomRight:
//               // Arrow pointing to the bottom-right
//               arrowPath.move(to: CGPoint(x: bounds.width - arrowWidth, y: bounds.height - arrowHeight))
//               arrowPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
//               arrowPath.addLine(to: CGPoint(x: bounds.width, y: bounds.height - arrowHeight))
           }

           arrowPath.close()
           
           // Set up the arrow layer with the new path
           arrowLayer.path = arrowPath.cgPath
           arrowLayer.fillColor = arrowColor.cgColor
           layer.sublayers?.forEach { $0.removeFromSuperlayer() } // Clear any existing layers
           layer.addSublayer(arrowLayer)
       }
    
       override func layoutSubviews() {
           super.layoutSubviews()
           createArrow() // Recreate the arrow path every time the view's layout is updated
       }
}
