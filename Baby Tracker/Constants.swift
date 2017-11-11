//
//  Constants.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/22/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

struct K {
    struct NibNames {
        // TODO: update this to use the acutal class name to make it more robust
        static let SignIn = "SignInVC"
    }

    struct Segues {
        // app launch
        static let LoggedIn = "LoggedInSegue"
        static let LoggedOut = "LoggedOutSegue"

        // logged out
        static let SignedIn = "SignedInSegue"
        static let SignUp = "SignUpSegue"

        // new account
        static let SignedUp = "SignedUpSegue"

        // home vc
        static let Feeding = "FeedingSegue"
        static let RequestFeature = "RequestFeatureSegue"

        // feeding vc
        static let FeedingHistory = "FeedingHistorySegue"
        static let UnwindToFeedingVC = "UnwindToFeedingVCSegue"

        // edit profile image
        static let EditProfileImage = "EditProfileImageSegue"
    }

    struct JsonFields {
        // feeding
        static let FeedingType = "type"
        static let Side = "side"
        static let StartDate = "startDate"
        static let EndDate = "endDate"
        static let LastPausedDate = "lastPausedDate"
        static let SupplyAmount = "supplyAmount"
        static let PausedTime = "pausedTime"
        static let FeedingQuantity = "quantity"
        static let Duration = "duration"

        // profile
        static let ParentName = "parentName"
        static let BabyName = "babyName"
        static let BabyDOB = "babyDOB"
        static let Email = "email"
        static let UserID = "userID"
        static let DesiredMaxSupply = "desiredMaxSupply"
    }

    struct Defaults {
        static let DefaultDesiredMaxSupply = 50.0
        static let BottleTopHeight = 70.0
        static let BottleFillOverlapWithBottomFillImage = 3.0
    }

    struct DictionaryKeys {
        static let VersionNumber = "CFBundleShortVersionString"
        static let BuildNumber = "CFBundleVersion"
    }
}
