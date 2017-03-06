//
//  FirebaseStorageFacade.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 3/6/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import Foundation
import Firebase

class FirebaseStorageFacade {
    
    private let storageReference = FIRStorage.storage().reference()
    
    func uploadData(data:Data, requestType type:FirebaseRequestType) {
        guard let path = pathForRequest(type: type) else { return }
        // Create a reference to the file you want to upload
        let fullReference = storageReference.child(path)
        
        // Upload the file to the path "images/rivers.jpg"
        fullReference.put(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            print("Success")
            // Metadata contains file metadata such as size, content-type, and download URL.
//            let downloadURL = metadata.downloadURL
        }
    }
    
    //TODO: make both firbase facades subclasses that include this and other common code
    private func pathForRequest(type:FirebaseRequestType) -> String? {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return nil
        }
        return "/users/" + uid + "/" + type.rawValue
    }

}
