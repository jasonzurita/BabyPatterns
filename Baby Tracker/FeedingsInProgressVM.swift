//
//  FeedingsInProgressVM.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/19/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

protocol FeedingsInProgressDelegate : class {
    func feedingCompleted(feedingEvent:FeedingEvent)
}

class FeedingsInProgressVM : BaseVM {
    private var feedingsInProgress:[FeedingInProgress] = []
    
    weak var delegate:FeedingsInProgressDelegate?
    
    func newPotentialFeeding(json:[String:Any], serverKey:String) {
        if let fip = FeedingInProgress(json: json, serverKey:serverKey) {
            feedingsInProgress.append(fip)
        }
    }
    
    func feedingStarted(type:FeedingType, side:FeedingSide) {
        guard feedingInProgress(type: type) == nil else {
            debugPrint(string: "Already a feeding started on this side...")
            return
        }
        let fip = FeedingInProgress(type: type, side: side)
        feedingsInProgress.append(fip)
        
        let serverKey = database.uploadFeedingEvent(withData: fip.eventJson(), requestType: fip.type)
        fip.serverKey = serverKey
    }
    
    func feedingEnded(type:FeedingType, side:FeedingSide) {
        
        guard let fip = feedingInProgress(type: type) else { return }
        
        fip.endTime = Date()
        fip.isPaused = false
        
        delegate?.feedingCompleted(feedingEvent:fip)
        
        feedingsInProgress = feedingsInProgress.filter { $0 !== fip }
        
        updateFeedingOnServer(fip: fip)
    }
    
    func updateFeedingInProgress(type:FeedingType, side:FeedingSide, isPaused:Bool) {
        guard let fip = feedingInProgress(type: type) else { return }
        
        if isPaused {
            fip.lastPausedDate = Date()
        } else if let lastPausedDate = fip.lastPausedDate {
            fip.pausedTime += abs(lastPausedDate.timeIntervalSinceNow)
            fip.lastPausedDate = nil
        }
        
        fip.isPaused = isPaused
        
        updateFeedingOnServer(fip:fip)
    }
    
    private func updateFeedingOnServer(fip:FeedingInProgress) {
        guard let serverKey = fip.serverKey else {
            debugPrint(string: "Did not update feeding on server because no server key found...")
            return
        }
        database.updateFeedingEvent(data: fip.eventJson(), serverKey: serverKey, requestType: fip.type)
    }
    
    //Change this to provide an array for feeding timers based on type. i.e., delete side from here to simplifiy
    func feedingInProgress(type:FeedingType) -> FeedingInProgress? {
        let feedings = feedingsInProgress.filter { $0.type == type }
        guard feedings.count != 0 else { return nil }
        guard feedings.count == 1, let feeding = feedings.first else {
            debugPrint(string: "Warning! More than one feeding of the same type...")
            return nil
        }
        return feeding
    }
}
