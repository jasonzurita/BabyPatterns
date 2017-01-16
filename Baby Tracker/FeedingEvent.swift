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
    let startTime:Date
    var endTime:Date?
    var pausedTime:TimeInterval
    var serverKey:String?
    
    let shouldPrintDebugString = true
    
    init(type:FeedingType, side:FeedingSide, startTime:Date, endTime:Date?, pausedTime:TimeInterval, serverKey:String?) {
        self.type = type
        self.side = side
        self.startTime = startTime
        self.endTime = endTime
        self.pausedTime = pausedTime
        self.serverKey = serverKey
    }
    
    func eventJson() -> [String:Any] {
        assertionFailure("This should be overriden by subclasses")
        return [:]
    }
    
    func duration() -> TimeInterval {
        return  floor(baseDuration() - pausedTime)
    }
    
    private func baseDuration() -> TimeInterval{
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        } else {
            return abs(startTime.timeIntervalSinceNow)
        }
    }
    
    func debugPrint(string:String) {
        if shouldPrintDebugString {
            print(String(describing: "-- Debug -- \(type(of:self)): " + string))
        }
    }
}
