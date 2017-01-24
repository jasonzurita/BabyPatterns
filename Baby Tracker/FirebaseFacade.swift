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
    typealias ResponseHandler = ([(data:[String:Any],serverKey:String)]) -> Void
    
    private let databaseReference = FIRDatabase.database().reference()
    private var databaseReferenceHandles: [(type: FeedingType, handle:FIRDatabaseHandle)] = []
    
    deinit {
        for referenceHandle in databaseReferenceHandles {
            self.databaseReference.child(referenceHandle.type.rawValue).removeObserver(withHandle: referenceHandle.handle)
        }
    }
    
    func configureDatabase(requestType:FirebaseRequestType, responseHandler: @escaping (ResponseHandler)) {
        debugPrint(string: "Configuring database...")
        
        guard let path = pathForRequest(type: requestType) else {
            debugPrint(string: "Configuration Failed! no user id")
            return
        }
        
        self.databaseReference.child(path).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            guard let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] else { return }
            let response = snapshots.map { ($0.value as! [String:Any], $0.key) }
            responseHandler(response)
        })
        
//        let handle = self.databaseReference.child(requestType.rawValue).observe(.childAdded, with: { [weak self] (snapshot) -> Void in
//            guard let strongSelf = self else { return }
//            if let json = snapshot.value as? Dictionary<String, String> {
//                responseHandler(json)
//                strongSelf.printDebugString(string: "Report \(requestType): \(json)")
//            }
//        })
//        databaseReferenceHandles.append((requestType, handle))
        debugPrint(string: "Database configured with request type: \(requestType.rawValue)")
    }
    
    func uploadFeedingEvent(withData data: [String:Any], requestType:FirebaseRequestType) -> String? {
        
        guard let path = pathForRequest(type: requestType) else {
            debugPrint(string: "Failed to upload data: \(data)")
            return nil
        }

        let serverKey = databaseReference.child(path).childByAutoId().key
        debugPrint(string: "Uploading data: \(data), with key: \(serverKey)")
        self.databaseReference.child(path).child(serverKey).setValue(data)
        
        return serverKey
    }
    
    func updateFeedingEvent(data: [String:Any], serverKey:String, requestType:FirebaseRequestType) {
        guard let path = pathForRequest(type: requestType) else {
            debugPrint(string: "Failed to update data: \(data)")
            return
        }

        debugPrint(string: "Updating data: \(data), with key: \(serverKey)")
        databaseReference.child(path).child(serverKey).updateChildValues(data)
    }
    
    private func pathForRequest(type:FirebaseRequestType) -> String? {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return nil
        }
        return "/users/" + uid + "/" + type.rawValue
    }
    
    private func debugPrint(string:String) {
        if shouldPrintDebugString {
            print(String(describing: "-- Debug -- \(type(of:self)): " + string))
        }
    }
    
}
