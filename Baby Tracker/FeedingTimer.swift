//
//  FeedingTimer.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/16/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

class FeedingTimer : FeedingEvent {
    var isPaused:Bool = false
    var endTime:Date?
    let startTime:Date
    var duration:TimeInterval = 0.0
    
    init(type:FeedingType, side:FeedingSide, startTime:Date) {
        self.startTime = startTime
        super.init(type: type, side: side)
    }
}
