//
//  FeedingEvent.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/16/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

class FeedingEvent {
    let type:FeedingType
    let side:FeedingSide
    
    init(type:FeedingType, side:FeedingSide) {
        self.type = type
        self.side = side
    }
    
    func eventJson() throws -> [String:String] {
        assertionFailure("This should be overriden by subclasses")
        return [:]
    }
}
