//
//  FeedingVM+Summary.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/19/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

extension FeedingVM {

    func feedingsMatching(type:FeedingType, isFinished:Bool) -> [Feeding] {
        return feedings.filter { $0.type == type && $0.isFinished == isFinished }
    }
    
    func finishedFeedings() -> [Feeding] {
        return feedingsMatching(type: .nursing, isFinished: false) + feedingsMatching(type: .bottle, isFinished: false)
    }
    
    func lastFeedingTime() -> Date? {
        
        guard let lft = finishedFeedings().last else {
            return nil
        }
        
        return lft.endDate
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        guard let lastFeedingTime = lastFeedingTime() else { return 0 }
        return abs(lastFeedingTime.timeIntervalSinceNow)
    }
    
    func lastFeedingSide() -> FeedingSide {
        return feedingsMatching(type: .nursing, isFinished: true).last?.side ?? .none
    }
    
    func averageFeedingDuration(filterWindow:DateInterval) -> TimeInterval? {
        let f = finishedFeedings()
        guard f.count > 0 else { return 0.0 }
        let sum = f.reduce(0.0, { $0 + $1.duration() })
        return sum / TimeInterval(f.count)
    }
}
