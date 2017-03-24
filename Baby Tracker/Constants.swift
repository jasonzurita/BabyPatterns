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
    
    //TODO: consider turn segues and constants in to enums
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
        static let UnwindToFeedingVCSegue = "UnwindToFeedingVCSegue"
        
        //edit profile image
        static let EditProfileImageSegue = "EditProfileImageSegue"
    }
    
    struct JsonFields {
        //feeding
        static let FeedingType = "type"
        static let Side = "side"
        static let StartDate = "startDate"
        static let EndDate = "endDate"
        static let LastPausedDate = "lastPausedDate"
        static let PausedTime = "pausedTime"
        static let FeedingQuantity = "quantity"
        static let Duration = "duration"
        
        //profile
        static let ParentName = "parentName"
        static let BabyName = "babyName"
        static let BabyDOB = "babyDOB"
        static let Email = "email"
        static let UserID = "userID"
    }
}
