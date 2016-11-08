//
//  FeedEvent.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/4/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

enum FeedingType {
    case Left
    case Right
    case Bottle
}

struct FeedEvent {
    let dateInterval:DateInterval
    let feedingType:FeedingType
}
