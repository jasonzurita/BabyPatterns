//
//  ProfileVM.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 2/22/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

class ProfileVM: BaseVM {
    var profile:Profile?
    
    func loadProfile(completionHandler:@escaping (Void) -> Void) {
        DatabaseFacade().configureDatabase(requestType: .profile, responseHandler: { responseArray in
            //TODO: respond with completion handler if this fails
            guard let data = responseArray.last else { completionHandler(); return }
            guard let babyName = data.json[K.JsonFields.BabyName] as? String else { completionHandler(); return  }
            guard let parentName = data.json[K.JsonFields.ParentName] as? String else { completionHandler(); return  }
            guard let email = data.json[K.JsonFields.Email] as? String else { completionHandler(); return  }
            guard let babyDOB = Date(timeInterval: data.json[K.JsonFields.BabyDOB]) else { completionHandler(); return  }
            
            self.profile = Profile(babyName: babyName, parentName: parentName, babyDOB: babyDOB, email: email, serverKey: data.serverKey)
            
            completionHandler()
        })
        
        StorageFacade().download(requestType: .profilePhoto, callback: { (data, error) in
            guard let data = data else {
                if let e = error {
                    print(e.localizedDescription)
                }
                return
            }
            if let image = UIImage(data: data) {
                self.profile?.profilePicture = image
            }
        })
    }
    
    func updateProfilePhoto(image:UIImage) {
        profile?.profilePicture = image
        let data = UIImagePNGRepresentation(image)
        StorageFacade().uploadData(data: data!, requestType: .profilePhoto)
    }
    
    func sendToServer() {
        guard let p = profile else { print("No profile to send to server..."); return }
        profile?.serverKey = DatabaseFacade().uploadJSON(p.json(), requestType: .profile)
    }
    
    func profileUpdated() {
        guard let p = profile, let serverKey = p.serverKey else { print("Error updating profile..."); return }
        DatabaseFacade().updateJSON(p.json(), serverKey: serverKey, requestType: .profile)
    }
}
