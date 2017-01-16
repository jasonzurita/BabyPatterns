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
        Bundle.main.loadNibNamed(String(describing: type(of:self)), owner: self, options: nil)
    }
}
