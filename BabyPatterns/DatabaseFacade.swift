//
//  DatabaseFacade.swift
//  BabyPatterns
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation
import Firebase
import Library
import Framework_BabyPatterns

struct DatabaseFacade: Loggable {
    let shouldPrintDebugLog = true

    typealias ResponseHandler = ([(json: [String: Any], serverKey: String)]) -> Void

    private let databaseReference = Database.database().reference()
    private var databaseReferenceHandles: [(type: FeedingType, handle: DatabaseHandle)] = []

    //    deinit {
    //        for referenceHandle in databaseReferenceHandles {
    //            self.databaseReference
    //    .child(referenceHandle.type.rawValue)
    //    .removeObserver(withHandle: referenceHandle.handle)
    //        }
    //    }

    func configureDatabase(requestType: FirebaseRequestType, responseHandler: @escaping (ResponseHandler)) {
        log("Configuring database with request Type: \(requestType.rawValue)...", object: self, type: .info)

        guard let path = pathForRequest(type: requestType) else {
            log("Configuration Failed! no user id", object: self, type: .error)
            return
        }

        databaseReference.child(path).observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            guard let snapshots = snapshot.children.allObjects as? [DataSnapshot] else { return }

            let response = snapshots.map { ($0.value as? [String: Any] ?? [:], $0.key) }
            responseHandler(response)
        })

        //  let handle = self.databaseReference.child(requestType.rawValue)
        //    .observe(.childAdded, with: { [weak self] (snapshot) -> Void in
        //            guard let strongSelf = self else { return }
        //            if let json = snapshot.value as? Dictionary<String, String> {
        //                responseHandler(json)
        //                strongSelf.printDebugString(string: "Report \(requestType): \(json)")
        //            }
        //        })
        //        databaseReferenceHandles.append((requestType, handle))

        log("Database configured with request type: \(requestType.rawValue)", object: self, type: .info)
    }

    func uploadJSON(_ json: [String: Any], requestType: FirebaseRequestType) -> String? {

        guard let path = pathForRequest(type: requestType) else {
            log("Failed to upload data: \(json)", object: self, type: .error)
            return nil
        }

        let serverKey = databaseReference.child(path).childByAutoId().key
        log("Uploading data: \(json), with key: \(serverKey)", object: self, type: .info)
        databaseReference.child(path).child(serverKey).setValue(json)

        return serverKey
    }

    func updateJSON(_ json: [String: Any], serverKey: String, requestType: FirebaseRequestType) {
        guard let path = pathForRequest(type: requestType) else {
            log("Failed to update data: \(json)", object: self, type: .error)
            return
        }

        log("Updating json: \(json), with key: \(serverKey)", object: self, type: .info)
        databaseReference.child(path).child(serverKey).updateChildValues(json)
    }

    private func pathForRequest(type: FirebaseRequestType) -> String? {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        return "/users/" + uid + "/" + type.rawValue
    }
}
