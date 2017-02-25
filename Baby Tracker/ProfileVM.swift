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
        FirebaseFacade().configureDatabase(requestType: .profile, responseHandler: { responseArray in
            //TODO: respond with completion handler if this fails
            guard let data = responseArray.last else { completionHandler(); return }
            guard let babyName = data.json[K.JsonFields.BabyName] as? String else { completionHandler(); return  }
            guard let parentName = data.json[K.JsonFields.ParentName] as? String else { completionHandler(); return  }
            guard let email = data.json[K.JsonFields.Email] as? String else { completionHandler(); return  }
            guard let babyDOB = Date(timeInterval: data.json[K.JsonFields.BabyDOB]) else { completionHandler(); return  }
            
            self.profile = Profile(babyName: babyName, parentName: parentName, profilePicture: UIImage(), babyDOB: babyDOB, email: email, serverKey: data.serverKey)
            
            completionHandler()
        })
    }
    
    func sendToServer() {
        guard let p = profile else { print("No profile to send to server..."); return }
        profile?.serverKey = database.uploadJSON(p.json(), requestType: .profile)
    }
    
    func profileUpdated() {
        guard let p = profile, let serverKey = p.serverKey else { print("Error updating profile..."); return }
        database.updateJSON(p.json(), serverKey: serverKey, requestType: .profile)
    }
}
