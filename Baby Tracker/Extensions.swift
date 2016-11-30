//
//  Extensions.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/29/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

extension Date {
    
    init?(_ string:String?) {
        guard let s = string, let interval = TimeInterval(s) else { return nil }
        self = Date(timeIntervalSince1970: interval)
    }
}

extension TimeInterval {
    func hours() -> TimeInterval{
        return self / 3600
    }
}
