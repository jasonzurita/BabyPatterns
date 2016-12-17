//
//  FeedingFacade.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/9/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

class FeedingFacade {
    
    private let shouldPrintDebugString = true
    private var database = FirebaseFacade()
    private var feedingsInProgress:[FeedingTimer] = []
    
    let nursing = Nursing()
    
    func loadData(completionHandler:@escaping (Void) -> Void) {

        database.configureDatabase(requestType: .nursing, responseHandler: { jsonArray in
            for json in jsonArray {
                self.nursing.processNewNursing(json: json)
            }
            completionHandler()
        })
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        return nursing.timeSinceLastFeeding()
    }
    
    func lastFeedingSide() -> FeedingSide {
        return nursing.lastFeedingSide()
    }
    
    func feedingStarted(type:FeedingType, side:FeedingSide) {
        let feeding = FeedingTimer(type: type, side: side)
        feedingsInProgress.append(feeding)
    }
    
    func feedingEnded(type:FeedingType, side:FeedingSide, duration:TimeInterval) {
        
        guard let feeding = feedingInProgress(type: type, side: side) else { return }
        
        feeding.endTime = Date()
        feeding.duration = duration
        feeding.isPaused = false
        guard let event = makeAndAddFeeding(feeding: feeding) else { return }
        try! database.uploadFeedingEvent(withData: event.eventJson(), requestType: event.type)
        feedingsInProgress = feedingsInProgress.filter { $0 !== feeding }
    }
    
    func updateFeedingInProgress(type:FeedingType, side:FeedingSide, duration:TimeInterval, isPaused:Bool) {
        guard let feeding = feedingInProgress(type: type, side: side) else { return }
        
        feeding.duration = duration
        feeding.isPaused = isPaused
    }
    
    //TODO: revisit this because it is ugly
    func makeAndAddFeeding(feeding:FeedingTimer) -> FeedingEvent? {
        var event:FeedingEvent?
        
        switch feeding.type {
        case .nursing:
            guard let endTime = feeding.endTime else { return nil }
            event = NursingEvent(type: feeding.type, side: feeding.side, duration: feeding.duration, endTime: endTime)
            nursing.nursings.append(event as! NursingEvent)
            return event
        case .bottle:
            break
        case .pumping:
            
            break
        case .none:
            assertionFailure("No feeding type!")
        }
        
        return event
    }
    
    func feedingInProgress(type:FeedingType, side:FeedingSide) -> FeedingTimer? {
        let feedings = feedingsInProgress.filter { $0.side == side && $0.type == type }
        guard feedings.count != 0 else { return nil }
        guard feedings.count == 1, let feeding = feedings.first else {
            printDebugString(string: "Warning! More than one feeding of the same type and side...")
            return nil
        }
        return feeding
    }
    
    private func printDebugString(string:String) {
        if shouldPrintDebugString {
            print(String(describing: "-- Debug -- \(type(of:self)): " + string))
        }
    }
}
