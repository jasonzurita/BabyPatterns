//
//  Enums.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/9/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

enum FeedingType : String {
    case nursing = "Nursing"
    case pumping = "Pumping"
    case bottle = "Bottle"
    case none = "None"
    
    static let allValues = [nursing, pumping, bottle]
}

enum FirebaseRequestType : String {
    case feedings = "feedings"
    case profile = "profile"
    case profilePhoto = "profilePhoto"
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

enum NursingEventJsonError: Error {
    case invalidNursingEvent
}

enum LogType: String {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}
