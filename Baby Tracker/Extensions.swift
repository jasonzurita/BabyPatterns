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

extension Double {
    func stringFromSecondsToHours() -> (string:String, remainder:Double) {
        let secondsToHours:Double = 3600
        let hours = floor(self / secondsToHours)
        let remainder = self - hours * secondsToHours
        
        return hours < 10 ? ("0\(Int(hours))", remainder) : ("\(Int(hours))", remainder)
    }
    
    func stringFromSecondsToMinutes() -> (string:String, remainder:Double) {
        let secondsToMinutes:Double = 60
        let minutes = floor(self / secondsToMinutes)
        let remainder = self - minutes * secondsToMinutes
        
        return minutes < 10 ? ("0\(Int(minutes))",remainder) : ("\(Int(minutes))", remainder)
    }
    
    func stringFromSecondsToSeconds() -> (string:String, remainder:Double) {
        let seconds = floor(self)
        let remainder = self - seconds
        
        return seconds < 10 ? ("0\(Int(seconds))",remainder) : ("\(Int(seconds))", remainder)
    }
}
