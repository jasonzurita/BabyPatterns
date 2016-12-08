//
//  FirebaseFacade.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation
import Firebase

class FirebaseFacade {
    
    private let shouldPrintDebugString = true
    
    private let databaseReference = FIRDatabase.database().reference()
    private var databaseReferenceHandles: [(type: FeedingType, handle:FIRDatabaseHandle)] = []
    
    deinit {
        for referenceHandle in databaseReferenceHandles {
            self.databaseReference.child(referenceHandle.type.rawValue).removeObserver(withHandle: referenceHandle.handle)
        }
    }
    
    func configureDatabase(requestType:FeedingType, responseHandler: @escaping (Dictionary<String,String>) -> Void ) {
        printDebugString(string: "Configuring database...")
        // Listen for new messages in the Firebase database
        self.databaseReference.child(requestType.rawValue).observeSingleEvent(of: .value, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            for child in snapshot.children {
                if let c = child as? FIRDataSnapshot, let json = c.value as? Dictionary<String, String> {
                    responseHandler(json)
                    strongSelf.printDebugString(string: "Report \(requestType): \(json)")
                }
            }

        })
        
//        let handle = self.databaseReference.child(requestType.rawValue).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
//            guard let strongSelf = self else { return }
//            if let json = snapshot.value as? Dictionary<String, String> {
//                responseHandler(json)
//                strongSelf.printDebugString(string: "Report \(requestType): \(json)")
//            }
//        })
//        databaseReferenceHandles.append((requestType, handle))
        printDebugString(string: "Database request type - \(requestType.rawValue)")
    }
    
    func uploadFeedingEvent(withData data: [String:String], feedingType:FeedingType) {
        printDebugString(string: "Uploading feeding data: \(data)")
        self.databaseReference.child(feedingType.rawValue).childByAutoId().setValue(data)
    }
    
    private func printDebugString(string:String) {
        if shouldPrintDebugString {
            print(String(describing: "-- Debug -- \(type(of:self)): " + string))
        }
    }
    
}
