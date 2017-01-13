//
//  NursingEvent.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

class NursingEvent: FeedingEvent {
    
    init?(json:Dictionary<String,Any>, serverKey:String) {
        guard let typeRawValue = json[Constants.JsonFields.FeedingType] as? String, let type = FeedingType(rawValue: typeRawValue) else { return nil }
        guard let sideRawValue = json[Constants.JsonFields.Side] as? Int, let side = FeedingSide(rawValue:sideRawValue) else { return nil }

        guard let startTime = Date(timeInterval:json[Constants.JsonFields.StartTime]) else { return nil }
        guard let endTime = Date(timeInterval:json[Constants.JsonFields.EndTime]) else { return nil }
        guard let pausedTime = json[Constants.JsonFields.PausedTime] as? TimeInterval else { return nil }
        
        super.init(type: type, side: side, startTime: startTime, endTime: endTime, pausedTime: pausedTime, serverKey:serverKey)
    }

//
//        if let quantityString = feedingJson[Constants.JsonFields.FeedingQuantity], let quantityDouble = Double(quantityString) {
//            quantity = quantityDouble
//        } else {
//            quantity = nil
//        }
    
    override func eventJson() -> [String:Any] {
        var json:[String : Any] = [Constants.JsonFields.FeedingType:type.rawValue,
                                   Constants.JsonFields.Side:side.rawValue,
                                   Constants.JsonFields.StartTime:startTime.timeIntervalSince1970,
                                   Constants.JsonFields.PausedTime:pausedTime]
        
        if let endTime = endTime {
            json[Constants.JsonFields.EndTime] = endTime.timeIntervalSinceNow
        } else {
            assertionFailure("Error: No end time for a complete feeding")
        }
       
        return json
    }
}
