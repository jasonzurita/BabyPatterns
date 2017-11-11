//
//  UIViewExtensions.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/16/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

extension UIView {
    func loadNib() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
    }

    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Cannot bind frame to superview because nil superview...")
            return
        }

        translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|",
                                                                options: .directionLeadingToTrailing,
                                                                metrics: nil,
                                                                views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|",
                                                                options: .directionLeadingToTrailing,
                                                                metrics: nil,
                                                                views: ["subview": self]))
    }
}
