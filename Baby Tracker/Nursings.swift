//
//  Nursings.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

enum NursingType: Int {
    case left = 1
    case right
}

struct Nursings {
    let dateInterval:DateInterval
    let quantity:Double?
    let feedingType:NursingType
    
    init?(feedingJson:Dictionary<String,String>) {
        guard let start = Date(feedingJson[Constants.JsonFields.StartTime]), let end = Date(feedingJson[Constants.JsonFields.EndTime]) else { return nil }
        guard let string = feedingJson[Constants.JsonFields.FeedingType], let int = Int(string), let type = NursingType(rawValue:int) else { return nil }
        
        dateInterval = DateInterval(start: start, end: end)
        feedingType = type
        
        if let quantityString = feedingJson[Constants.JsonFields.FeedingQuantity], let quantityDouble = Double(quantityString) {
            quantity = quantityDouble
        } else {
            quantity = nil
        }
    }
}
