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
        
        guard let path = pathForRequest(type: requestType) else {
            printDebugString(string: "Configuration Failed! no user id")
            return
        }
        
        self.databaseReference.child(path).observeSingleEvent(of: .value, with: { [weak self] (snapshot) -> Void in
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
        printDebugString(string: "Database configured with request type: \(requestType.rawValue)")
    }
    
    func uploadFeedingEvent(withData data: [String:String], requestType:FeedingType) {
        
        guard let path = pathForRequest(type: requestType) else {
            printDebugString(string: "Failed to upload data: \(data)")
            return
        }

        printDebugString(string: "Uploading data: \(data)")
        self.databaseReference.child(path).childByAutoId().setValue(data)
    }
    
    private func pathForRequest(type:FeedingType) -> String? {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return nil
        }
        return "/users/" + uid + "/" + type.rawValue
    }
    
    private func printDebugString(string:String) {
        if shouldPrintDebugString {
            print(String(describing: "-- Debug -- \(type(of:self)): " + string))
        }
    }
    
}
