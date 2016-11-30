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
    
    var allFeedings:[FeedEvent] = []
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
                strongSelf.allFeedings.append(feeding)
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
        guard let lft = allFeedings.last else {
            return Date()
        }
        
        return lft.dateInterval.end
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        return lastFeedingTime().timeIntervalSinceNow
    }
    
    func averageFeedingDuration(filterWindow:DateInterval) -> TimeInterval {
        guard allFeedings.count > 0 else { return 0.0 }
        let sum = allFeedings.reduce(0.0, { $0 + $1.dateInterval.duration })
        
        return sum / TimeInterval(allFeedings.count)
    }
    
    private func printDebugString(string:String) {
        if shouldPrintDebugString {
            print(String(describing: "-- Debug -- \(type(of:self)): " + string))
        }
    }
}
