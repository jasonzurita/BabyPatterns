//
//  Enums.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/9/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

enum FeedingType : String {
    case nursing = "nursings"
    case bottle = "bottleFeedings"
    case pumping = "pumpings"
}

enum FeedingSide: Int {
    case left = 1
    case right
    case none
    
    func asText() -> String {
        switch self {
        case .left:
            return "Left"
        case .right:
            return "Right"
        case .none:
            return ""
        }
    }
}
