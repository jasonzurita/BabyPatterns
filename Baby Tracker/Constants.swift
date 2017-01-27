//
//  Constants.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/22/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

struct K {
    struct NibNames {
        static let SignIn = "SignInVC"
    }
    
    struct Segues {
        //app launch
        static let LoggedInSegue = "LoggedInSegue"
        static let LoggedOutSegue = "LoggedOutSegue"
        
        //logged out
        static let SignedInSegue = "SignedInSegue"
        static let SignUpSegue = "SignUpSegue"
        
        //new account
        static let SignedUpSegue = "SignedUpSegue"
        
        //home vc
        static let FeedingSegue = "FeedingSegue"
        
        //feeding vc
        static let FeedingHistorySegue = "FeedingHistorySegue"
    }
    
    struct JsonFields {
        static let FeedingType = "type"
        static let Side = "side"
        static let StartDate = "startDate"
        static let EndDate = "endDate"
        static let LastPausedDate = "lastPausedDate"
        static let PausedTime = "pausedTime"
        static let FeedingQuantity = "quantity"
        static let Duration = "duration"
    }
}
