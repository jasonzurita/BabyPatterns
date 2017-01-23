//
//  Feeding.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/16/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

struct Feeding {
    let type:FeedingType
    let side:FeedingSide
    let startDate:Date
    var endDate:Date?
    var lastPausedDate:Date?
    var pausedTime:TimeInterval
    var serverKey:String?
    
    let shouldPrintDebugString = true
    
    var isPaused:Bool {
        return lastPausedDate != nil
    }
    
    var isFinished:Bool {
        return endDate != nil
    }
    
    init(type:FeedingType, side:FeedingSide, startDate:Date, endDate:Date? = nil, lastPausedDate:Date? = nil, pausedTime:TimeInterval = 0.0, serverKey:String? = nil) {
        self.type = type
        self.side = side
        self.startDate = startDate
        self.endDate = endDate
        self.lastPausedDate = lastPausedDate
        self.pausedTime = pausedTime
        self.serverKey = serverKey
    }
    
    init?(json:Dictionary<String,Any>, serverKey:String) {
        guard let typeRawValue = json[Constants.JsonFields.FeedingType] as? String, let type = FeedingType(rawValue: typeRawValue) else { return nil }
        guard let sideRawValue = json[Constants.JsonFields.Side] as? Int, let side = FeedingSide(rawValue:sideRawValue) else { return nil }
        
        guard let startDate = Date(timeInterval:json[Constants.JsonFields.StartDate]) else { return nil }
        let endDate = Date(timeInterval:json[Constants.JsonFields.EndDate])
        
        let lastPausedDate = Date(timeInterval:json[Constants.JsonFields.LastPausedDate])
        guard let pausedTime = json[Constants.JsonFields.PausedTime] as? TimeInterval else { return nil }
                
        self.init(type:type, side:side, startDate:startDate, endDate:endDate, lastPausedDate: lastPausedDate, pausedTime:pausedTime, serverKey:serverKey)
    }
    
    func eventJson() -> [String:Any] {
        let json:[String : Any] = [Constants.JsonFields.FeedingType : type.rawValue,
                                   Constants.JsonFields.Side : side.rawValue,
                                   Constants.JsonFields.StartDate : startDate.timeIntervalSince1970,
                                   Constants.JsonFields.PausedTime : pausedTime,
                                   Constants.JsonFields.EndDate : endDate?.timeIntervalSince1970 ?? 0.0,
                                   Constants.JsonFields.LastPausedDate : lastPausedDate?.timeIntervalSince1970 ?? 0.0]
        
        return json
    }
    
    func duration() -> TimeInterval {
        return floor(baseDuration() - fullPausedTime())
    }
    
    private func baseDuration() -> TimeInterval {
        if let endDate = endDate {
            return endDate.timeIntervalSince(startDate)
        } else {
            return abs(startDate.timeIntervalSinceNow)
        }
    }
    
    private func fullPausedTime() -> TimeInterval {
        var adjustment:TimeInterval = 0.0
        if let lastPausedDate = lastPausedDate {
            adjustment = abs(lastPausedDate.timeIntervalSinceNow)
        }
        
        return pausedTime + adjustment
    }
    
    func debugPrint(string:String) {
        if shouldPrintDebugString {
            print(String(describing: "-- Debug -- \(type(of:self)): " + string))
        }
    }
}
