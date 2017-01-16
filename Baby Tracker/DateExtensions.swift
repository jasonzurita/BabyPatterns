//
//  DateExtensions.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/16/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import Foundation

extension Date {
    
    init?(timeInterval:Any?) {
        guard let i = timeInterval as? TimeInterval, i > 0 else { return nil }
        self = Date(timeIntervalSince1970: i)
    }
}

