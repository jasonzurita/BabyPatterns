//
//  FeedingInProgress.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/16/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

class FeedingInProgress : FeedingEvent {
    var lastPausedDate:Date?
    var isPaused = false
    
    init(type: FeedingType, side: FeedingSide) {
        super.init(type: type, side: side, startTime: Date(), endTime: nil, pausedTime: 0, serverKey:nil)
    }
    
    init?(json:Dictionary<String,Any>, serverKey:String) {
        guard let typeRawValue = json[Constants.JsonFields.FeedingType] as? String, let type = FeedingType(rawValue: typeRawValue) else { return nil }
        guard let sideRawValue = json[Constants.JsonFields.Side] as? Int, let side = FeedingSide(rawValue:sideRawValue) else { return nil }
        
        guard let startTime = Date(timeInterval:json[Constants.JsonFields.StartTime]) else { return nil }
        guard Date(timeInterval:json[Constants.JsonFields.EndTime]) == nil else { return nil }
        
        guard let pausedTime = json[Constants.JsonFields.PausedTime] as? TimeInterval else { return nil }
        let lastPausedDate = Date(timeInterval:json[Constants.JsonFields.LastPausedTime])
        self.isPaused = json[Constants.JsonFields.IsPaused] as? Bool ?? false
        self.lastPausedDate = lastPausedDate

        super.init(type: type, side: side, startTime: startTime, endTime: nil, pausedTime: pausedTime, serverKey: serverKey)
    }
    
    override func eventJson() -> [String:Any] {
        //TODO: make this function a throwing function again
        
        var json:[String : Any] = [Constants.JsonFields.FeedingType:type.rawValue,
                                   Constants.JsonFields.Side:side.rawValue,
                                   Constants.JsonFields.StartTime:startTime.timeIntervalSince1970,
                                   Constants.JsonFields.PausedTime:pausedTime,
                                   Constants.JsonFields.IsPaused:isPaused]
        
        if endTime == nil {
            debugPrint(string: "Feeding not finished...")
        }
        
        if let lastPaused = lastPausedDate {
            json[Constants.JsonFields.LastPausedTime] = lastPaused.timeIntervalSince1970
        }
        
        return json
    }
}
