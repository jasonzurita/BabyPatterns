//
//  Extensions.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/29/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    init?(_ string:String?) {
        guard let s = string, let interval = TimeInterval(s) else { return nil }
        self = Date(timeIntervalSince1970: interval)
    }
}

extension UIView {
    func loadNib() {
        Bundle.main.loadNibNamed(String(describing: type(of:self)), owner: self, options: nil)
    }
}
