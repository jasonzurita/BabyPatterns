//
//  FeedingsVM+FeedingInProgress.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/19/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

extension FeedingsVM {
    
    func feedingStarted(type:FeedingType, side:FeedingSide) {
        guard feedingInProgress(type: type) == nil else {
            debugPrint(string: "Already a feeding started on this side...")
            return
        }
        
        var fip = Feeding(type: type, side: side, startDate: Date())
        let serverKey = DatabaseFacade().uploadJSON(fip.eventJson(), requestType: .feedings)
        fip.serverKey = serverKey
        feedings.append(fip)
    }
    
    func feedingEnded(type:FeedingType, side:FeedingSide) {
        
        guard var fip = feedingInProgress(type: type) else { return }

        fip.endDate = Date()
        fip.lastPausedDate = nil
        
        updateInternalFeedingCache(fip: fip)
        updateFeedingOnServer(fip: fip)
    }
    
    func updateFeedingInProgress(type:FeedingType, side:FeedingSide, isPaused:Bool) {
        guard var fip = feedingInProgress(type: type) else { return }
        
        if isPaused {
            fip.lastPausedDate = Date()
        } else if let lastPausedDate = fip.lastPausedDate {
            fip.pausedTime += abs(lastPausedDate.timeIntervalSinceNow)
            fip.lastPausedDate = nil
        }
        
        updateInternalFeedingCache(fip: fip)
        updateFeedingOnServer(fip:fip)
    }
    
    private func updateInternalFeedingCache(fip:Feeding) {
        //TODO: implement an == definition in the Feeding class to make this more robust
        if let i = feedings.index(where:{ $0.serverKey == fip.serverKey }) {
            feedings[i] = fip
        }
    }
    
    private func updateFeedingOnServer(fip:Feeding) {
        guard let serverKey = fip.serverKey else {
            debugPrint(string: "Did not update feeding on server because no server key found...")
            return
        }
        DatabaseFacade().updateJSON(fip.eventJson(), serverKey: serverKey, requestType: .feedings)
    }
    
    //Change this to provide an array for feeding timers based on type. i.e., delete side from here to simplifiy
    func feedingInProgress(type:FeedingType) -> Feeding? {
        let f = feedings.filter { $0.type == type && !$0.isFinished}
        guard f.count != 0 else { return nil }
        guard f.count == 1, let feeding = f.first else {
            debugPrint(string: "Warning! More than one feeding of the same type...")
            return nil
        }
        return feeding
    }
}
