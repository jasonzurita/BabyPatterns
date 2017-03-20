//
//  DatabaseFacade.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation
import Firebase

struct DatabaseFacade {
    
    private let shouldPrintDebugString = true
    typealias ResponseHandler = ([(json:[String:Any], serverKey:String)]) -> Void
    
    private let databaseReference = FIRDatabase.database().reference()
    private var databaseReferenceHandles: [(type: FeedingType, handle:FIRDatabaseHandle)] = []
    
//    deinit {
//        for referenceHandle in databaseReferenceHandles {
//            self.databaseReference.child(referenceHandle.type.rawValue).removeObserver(withHandle: referenceHandle.handle)
//        }
//    }
    
    func configureDatabase(requestType:FirebaseRequestType, responseHandler: @escaping (ResponseHandler)) {
        Logger.log(message: "Configuring database with request Type: \(requestType.rawValue)...", object: self, type: .info, shouldPrintDebugLog: shouldPrintDebugString)
        
        guard let path = pathForRequest(type: requestType) else {
            Logger.log(message: "Configuration Failed! no user id", object: self, type: .error, shouldPrintDebugLog: shouldPrintDebugString)
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
        Logger.log(message: "Database configured with request type: \(requestType.rawValue)", object: self, type: .info, shouldPrintDebugLog: shouldPrintDebugString)
    }
    
    func uploadJSON(_ json: [String:Any], requestType:FirebaseRequestType) -> String? {
        
        guard let path = pathForRequest(type: requestType) else {
            Logger.log(message: "Failed to upload data: \(json)", object: self, type: .error, shouldPrintDebugLog: shouldPrintDebugString)
            return nil
        }

        let serverKey = databaseReference.child(path).childByAutoId().key
        Logger.log(message: "Uploading data: \(json), with key: \(serverKey)", object: self, type: .info, shouldPrintDebugLog: shouldPrintDebugString)
        self.databaseReference.child(path).child(serverKey).setValue(json)
        
        return serverKey
    }
    
    func updateJSON(_ json: [String:Any], serverKey:String, requestType:FirebaseRequestType) {
        guard let path = pathForRequest(type: requestType) else {
            Logger.log(message: "Failed to update data: \(json)", object: self, type: .error, shouldPrintDebugLog: shouldPrintDebugString)
            return
        }

        Logger.log(message: "Updating json: \(json), with key: \(serverKey)", object: self, type: .info, shouldPrintDebugLog: shouldPrintDebugString)
        databaseReference.child(path).child(serverKey).updateChildValues(json)
    }
    
    private func pathForRequest(type:FirebaseRequestType) -> String? {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return nil
        }
        return "/users/" + uid + "/" + type.rawValue
    }
}