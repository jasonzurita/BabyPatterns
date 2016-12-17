//
//  NursingEvent.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation



class NursingEvent: FeedingEvent {
    
    let duration:TimeInterval
    let endTime:Date
    
    init(type:FeedingType, side:FeedingSide, duration:TimeInterval, endTime:Date) {
        self.duration = duration
        self.endTime = endTime
        super.init(type: type, side: side)
    }
    
    init?(feedingJson:Dictionary<String,String>) {
        guard let endTime = Date(feedingJson[Constants.JsonFields.EndTime]) else { return nil }
        guard let sideString = feedingJson[Constants.JsonFields.Side], let int = Int(sideString), let side = FeedingSide(rawValue:int) else { return nil }
        guard let durationString = feedingJson[Constants.JsonFields.Duration], let duration = Double(durationString) else { return nil }

        self.duration = duration
        self.endTime = endTime
        super.init(type: .nursing, side: side)
    }

//
//        if let quantityString = feedingJson[Constants.JsonFields.FeedingQuantity], let quantityDouble = Double(quantityString) {
//            quantity = quantityDouble
//        } else {
//            quantity = nil
//        }
    
    override func eventJson() throws -> [String:String] {
        return ["endTime":String(endTime.timeIntervalSince1970),
                "side":String(side.rawValue),
                "duration":String(duration)]
    }
}
