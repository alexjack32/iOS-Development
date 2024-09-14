//
//  NSLayoutConstraint+Extension.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 8/18/24.
//

import UIKit

extension NSLayoutConstraint {
    static func constraints(pinning view: UIView,
                            to superView: UIView,
                            top: CGFloat = 0,
                            leading: CGFloat = 0,
                            trailing: CGFloat = 0,
                            bottom: CGFloat = 0
    ) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        return [
            view.topAnchor.constraint(equalTo: superView.topAnchor, 
                                      constant: top),
            view.leadingAnchor.constraint(equalTo: superView.leadingAnchor, 
                                          constant: leading),
            view.trailingAnchor.constraint(equalTo: superView.trailingAnchor,
                                           constant: -trailing),
            view.bottomAnchor.constraint(equalTo: superView.bottomAnchor,
                                        constant: -bottom)
        ]
    }
}
