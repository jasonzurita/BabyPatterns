//
//  Shakeable.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 4/10/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

protocol Shakeable {
    func shake()
}

extension Shakeable where Self: UIView {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 6
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 20.0, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 20.0, y: center.y))
        layer.add(animation, forKey: "position")
    }
}
