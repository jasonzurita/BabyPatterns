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
    
    func processNewNursing(json: [String:String]) {
        if let nursingEvent = NursingEvent(feedingJson: json) {
            nursings.append(nursingEvent)
        }
    }
    
    func lastFeedingTime() -> Date? {
        guard let lft = nursings.last else {
            return nil
        }
        
        return lft.endTime
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        guard let lastFeedingTime = lastFeedingTime() else { return 0 }
        return abs(lastFeedingTime.timeIntervalSinceNow)
    }
    
    func lastFeedingSide() -> FeedingSide {
        if let lf = nursings.last {
            return lf.side
        }
        
        return .none
    }
    
    func averageFeedingDuration(filterWindow:DateInterval) -> TimeInterval {
        guard nursings.count > 0 else { return 0.0 }
        let sum = nursings.reduce(0.0, { $0 + $1.duration })
        return sum / TimeInterval(nursings.count)
    }
}
