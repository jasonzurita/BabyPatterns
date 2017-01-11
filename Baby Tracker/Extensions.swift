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
    
    init?(_ interval:Any?) {
        guard let i = interval as? TimeInterval else { return nil }
        self = Date(timeIntervalSince1970: i)
    }
}

extension UIView {
    func loadNib() {
        Bundle.main.loadNibNamed(String(describing: type(of:self)), owner: self, options: nil)
    }
}

extension Double {
    //TODO make these a generic function
    func stringFromSecondsToHours(zeroPadding:Bool) -> (string:String, remainder:Double) {
        let secondsToHours:Double = 3600
        let hours = floor(self / secondsToHours)
        let remainder = self - hours * secondsToHours
        
        var returnString = "\(Int(hours))"
        if zeroPadding && hours < 10{
            returnString = "0\(Int(hours))"
        }
        
        return (returnString, remainder)
    }
    
    func stringFromSecondsToMinutes(zeroPadding:Bool) -> (string:String, remainder:Double) {
        let secondsToMinutes:Double = 60
        let minutes = floor(self / secondsToMinutes)
        let remainder = self - minutes * secondsToMinutes
        
        var returnString = "\(Int(minutes))"
        if zeroPadding && minutes < 10{
            returnString = "0\(Int(minutes))"
        }
        
        return (returnString, remainder)
    }
    
    func stringFromSecondsToSeconds(zeroPadding:Bool) -> (string:String, remainder:Double) {
        let seconds = self.rounded()
        let remainder = self - seconds
        
        var returnString = "\(Int(seconds))"
        if zeroPadding && seconds < 10{
            returnString = "0\(Int(seconds))"
        }
        
        return (returnString, remainder)
    }
}
