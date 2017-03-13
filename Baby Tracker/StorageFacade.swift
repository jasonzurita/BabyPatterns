//
//  StorageFacade.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 3/6/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import Foundation
import Firebase

struct StorageFacade {
    
    private let storageReference = FIRStorage.storage().reference()
    typealias DownloadResponseHandler = (_ data:Data?, _ error:Error?) -> Void
    
    func uploadData(data:Data, requestType type:FirebaseRequestType) {
        print("uploading picture...")
        guard let fullReference = pathForRequest(type: type) else { print("poop....");return }
        
        // Upload the file to the path "images/rivers.jpg"
        fullReference.put(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print("Failure...")
                return
            }
            print("Success")
            // Metadata contains file metadata such as size, content-type, and download URL.
//            let downloadURL = metadata.downloadURL
        }
    }
    
    func download(requestType type:FirebaseRequestType, callback:@escaping DownloadResponseHandler) {
        guard let fullReference = pathForRequest(type: type) else { return }
        
        //TODO: wrap data & error in a request object
        fullReference.data(withMaxSize: 100 * 1024 * 1024, completion: { (data, error) in
            callback(data, error)
        })
    }
    
    private func pathForRequest(type:FirebaseRequestType) -> FIRStorageReference? {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return nil
        }
        return storageReference.child("/users/" + uid + "/" + type.rawValue)
    }

}
