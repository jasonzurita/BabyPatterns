//
//  StorageFacade.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 3/6/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import Foundation
import Firebase

struct StorageFacade: Loggable {
    let shouldPrintDebugLog = true

    private let storageReference = FIRStorage.storage().reference()
    typealias DownloadResponseHandler = (_ data: Data?, _ error: Error?) -> Void

    func uploadData(data: Data, requestType type: FirebaseRequestType) {
        log("Uploading \(type.rawValue)...", object: self, type: .info)
        guard let fullReference = pathForRequest(type: type) else {
            let message = "Couldn't make full storage reference for path with request type: \(type.rawValue)"
            log(message, object: self, type: .error)
            return
        }

        fullReference.put(data, metadata: nil) { (metadata, error) in
            guard metadata != nil && error == nil else {
                //TODO: handle error?
                self.log("Failure uploading \(type.rawValue)", object: self, type: .error)
                return
            }
            self.log("Upload complete! - \(type.rawValue)", object: self, type: .info)
        }
    }

    func download(requestType type: FirebaseRequestType, callback: @escaping DownloadResponseHandler) {
        guard let fullReference = pathForRequest(type: type) else { return }

        //TODO: wrap data & error in a request object
        fullReference.data(withMaxSize: 100 * 1024 * 1024, completion: { (data, error) in
            callback(data, error)
        })
    }

    private func pathForRequest(type: FirebaseRequestType) -> FIRStorageReference? {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return nil
        }
        return storageReference.child("/users/" + uid + "/" + type.rawValue)
    }

}
