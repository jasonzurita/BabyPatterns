//
//  Feedings.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/4/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation
import Firebase

class Feedings {
    private let shouldPrintDebugString = true
    
    var feedings:[FeedEvent] = []
    private let databaseReference = FIRDatabase.database().reference()
    private var databaseReferenceHandle: FIRDatabaseHandle!
    
    init() {
        configureDatabase()
//        sendMessage(withData: ["hello":"no way!"])
    }
    
    deinit {
        self.databaseReference.child("feedings").removeObserver(withHandle: databaseReferenceHandle)
    }
    
    private func configureDatabase() {
        printDebugString(string: "Configuring database...")
        // Listen for new messages in the Firebase database
        databaseReferenceHandle = self.databaseReference.child("feedings").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            if let json = snapshot.value as? Dictionary<String, String>, let feeding = FeedEvent(feedingJson: json)  {
                strongSelf.feedings.append(feeding)
                strongSelf.printDebugString(string: "Adding feeding \(feeding)")
            }
        })
        printDebugString(string: "Database Reference - \(databaseReferenceHandle)")
    }
//    
//    func sendMessage(withData data: [String: String]) {
//        printDebugString(string: "Sending message")
//        var mdata = data
//        mdata["name"] = "Jason"
//        // Push data to Firebase Database
//        self.databaseReference.child("feedings").childByAutoId().setValue(mdata)
//    }
    
    func lastFeedingTime() -> Date {
        guard let lft = feedings.last else {
            return Date()
        }
        
        return lft.dateInterval.start
    }
    
    func averageFeedingDuration(filterWindow:DateInterval) -> TimeInterval {
        return 0.0
    }
    
    private func printDebugString(string:String) {
        if shouldPrintDebugString {
            print(String(describing: "-- Debug -- \(type(of:self)): " + string))
        }
    }
}
