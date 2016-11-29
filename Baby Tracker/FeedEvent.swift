//
//  FeedEvent.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/4/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

enum FeedingType: Int {
    case left = 1
    case right
    case bottle
}

struct FeedEvent {
    let dateInterval:DateInterval
    let feedingType:FeedingType
    
    init?(feedingJson:Dictionary<String,String>) {
        guard let start = Date(feedingJson[Constants.JsonFields.StartTime]), let end = Date(feedingJson[Constants.JsonFields.EndTime]) else { return nil }
        guard let string = feedingJson[Constants.JsonFields.FeedingType], let int = Int(string), let type = FeedingType(rawValue:int) else { return nil }
        
        dateInterval = DateInterval(start: start, end: end)
        feedingType = type
    }
}
