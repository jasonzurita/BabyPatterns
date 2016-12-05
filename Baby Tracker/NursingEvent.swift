//
//  NursingEvent.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

struct NursingEvent {
    let dateInterval:DateInterval
    let side:FeedingSide
    
    init(start:Date, end:Date, side:FeedingSide) {
        dateInterval = DateInterval(start: start, end: end)
        self.side = side
    }
    
    init?(feedingJson:Dictionary<String,String>) {
        guard let start = Date(feedingJson[Constants.JsonFields.StartTime]), let end = Date(feedingJson[Constants.JsonFields.EndTime]) else { return nil }
        guard let string = feedingJson[Constants.JsonFields.Side], let int = Int(string), let type = FeedingSide(rawValue:int) else { return nil }
        
        dateInterval = DateInterval(start: start, end: end)
        side = type
//        
//        if let quantityString = feedingJson[Constants.JsonFields.FeedingQuantity], let quantityDouble = Double(quantityString) {
//            quantity = quantityDouble
//        } else {
//            quantity = nil
//        }
    }
    
    func eventJson() -> [String:String] {
        return ["startTime":String(dateInterval.start.timeIntervalSince1970),
                "endTime":String(dateInterval.end.timeIntervalSince1970),
                "side":String(side.rawValue)]
    }
}
