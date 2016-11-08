//
//  FoodRecord.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/4/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

struct FoodRecord {
    var feedings:[FeedEvent]

    func lastFeedingTime() -> Date {
        guard let lft = feedings.last else {
            return Date()
        }
        
        return lft.dateInterval.start
    }
    
    func averageFeedingDuration(filterWindow:DateInterval) -> TimeInterval {
        return 0.0
    }
}
