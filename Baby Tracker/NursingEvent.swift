//
//  NursingEvent.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

enum NursingEventJsonError : Error {
    case invalidNursingEvent
}

struct NursingEvent: FeedingEvent {
    let startTime:Date
    var endTime:Date?
    let side:FeedingSide
    let feedingType:FeedingType = .nursing
    
    var isValid:Bool {
        return endTime != nil
    }
    
    init(start:Date, end:Date?, side:FeedingSide) {
        startTime = start
        endTime = end
        self.side = side
    }
    
    init?(feedingJson:Dictionary<String,String>) {
        guard let start = Date(feedingJson[Constants.JsonFields.StartTime]), let end = Date(feedingJson[Constants.JsonFields.EndTime]) else { return nil }
        guard let string = feedingJson[Constants.JsonFields.Side], let int = Int(string), let type = FeedingSide(rawValue:int) else { return nil }
        
        startTime = start
        endTime = end
        side = type
//        
//        if let quantityString = feedingJson[Constants.JsonFields.FeedingQuantity], let quantityDouble = Double(quantityString) {
//            quantity = quantityDouble
//        } else {
//            quantity = nil
//        }
    }
    
    mutating func endEvent() {
        endTime = Date()
    }
    
    func eventJson() throws -> [String:String] {
        guard let endTime = endTime else { throw NursingEventJsonError.invalidNursingEvent }
        return ["startTime":String(startTime.timeIntervalSince1970),
                "endTime":String(endTime.timeIntervalSince1970),
                "side":String(side.rawValue)]
    }
}
