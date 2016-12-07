//
//  FeedingService.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

enum FeedingType : String {
    case nursing = "nursings"
    case bottle = "bottleFeedings"
    case pumping = "pumpings"
}

enum FeedingSide: Int {
    case left = 1
    case right
}

class FeedingService {

    static let shared = FeedingService()
    
    private let database = FirebaseFacade()
    
    let nursing = Nursing()
    
    init() {
        database.configureDatabase(requestType: .nursing, responseHandler: { json in
            if self.nursing.processNewNursing(json: json) {
            }
        })
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        return nursing.timeSinceLastFeeding()
    }
    
    func feedingStarted(type:FeedingType, start:Date, side:FeedingSide?) {

    }
    
    func feedingEnded(type:FeedingType, end:Date, side:FeedingSide?) {
        
    }
    
    func addFeedingEvent(type:FeedingType, start:Date, end:Date, side:FeedingSide?) {
        switch type {
        case .nursing:
            guard let s = side else { return }
            let nursingEvent = NursingEvent(start: start, end: end, side: s)
            nursing.nursings.append(nursingEvent)
            try! database.uploadFeedingEvent(withData: nursingEvent.eventJson(), feedingType: .nursing)
        case .bottle:
            break
        case .pumping:
            break
        }
    }
}
