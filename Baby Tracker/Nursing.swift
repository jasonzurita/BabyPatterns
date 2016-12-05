//
//  Nursing.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

class Nursing {
    var nursings: [NursingEvent] = []
    
    func processNewNursing(json: Dictionary<String,String>) -> Bool {
        if let nursingEvent = NursingEvent(feedingJson: json) {
            nursings.append(nursingEvent)
            return true
        }
        return false
    }
    
    func lastFeedingTime() -> Date {
        guard let lft = nursings.last else {
            return Date()
        }
        
        return lft.dateInterval.end
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        return abs(lastFeedingTime().timeIntervalSinceNow)
    }
    
    func averageFeedingDuration(filterWindow:DateInterval) -> TimeInterval {
        guard nursings.count > 0 else { return 0.0 }
        let sum = nursings.reduce(0.0, { $0 + $1.dateInterval.duration })
        
        return sum / TimeInterval(nursings.count)
    }
}
