//
//  Nursing.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

class Nursing {
    var nursingEvents: [NursingEvent] = []
    
    func newPotentialNursing(json: [String:Any], serverKey:String) {
        if let nursingEvent = NursingEvent(json: json, serverKey:serverKey) {
            nursingEvents.append(nursingEvent)
        }
    }
    
    func lastFeedingTime() -> Date? {
        guard let lft = nursingEvents.last else {
            return nil
        }
        
        return lft.endTime
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        guard let lastFeedingTime = lastFeedingTime() else { return 0 }
        return abs(lastFeedingTime.timeIntervalSinceNow)
    }
    
    func lastFeedingSide() -> FeedingSide {
        if let lf = nursingEvents.last {
            return lf.side
        }
        
        return .none
    }
    
    func averageFeedingDuration(filterWindow:DateInterval) -> TimeInterval? {
        guard nursingEvents.count > 0 else { return 0.0 }
        let sum = nursingEvents.reduce(0.0, { $0 + $1.duration() })
        return sum / TimeInterval(nursingEvents.count)
    }
}
