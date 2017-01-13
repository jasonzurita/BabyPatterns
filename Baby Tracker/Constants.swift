//
//  Constants.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/22/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

struct Constants {
    struct NibNames {
        static let SignIn = "SignInVC"
    }
    
    struct Segues {
        static let SignInSegue = "SignInSegue"
        static let SignUpSegue = "SignUpSegue"
        static let FeedingSegue = "FeedingSegue"
    }
    
    struct JsonFields {
        static let StartTime = "startTime"
        static let EndTime = "endTime"
        static let PausedTime = "pausedTime"
        static let Side = "side"
        static let FeedingType = "type"
        static let FeedingQuantity = "quantity"
        static let Duration = "duration"
        static let IsPaused = "isPaused"
        static let LastPausedTime = "lastPausedTime"
    }
    
    struct Feeding {
        static let FeedingTimeMarginOfError = 2.0
    }
}
