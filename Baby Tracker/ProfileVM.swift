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
            guard let profile = responseArray.last?.json else { completionHandler(); return }
            guard let babyName = profile[K.JsonFields.BabyName] as? String else { completionHandler(); return  }
            guard let parentName = profile[K.JsonFields.ParentName] as? String else { completionHandler(); return  }
            guard let email = profile[K.JsonFields.Email] as? String else { completionHandler(); return  }
            guard let babyDOB = Date(timeInterval: profile[K.JsonFields.BabyDOB]) else { completionHandler(); return  }
            
            self.profile = Profile(babyName: babyName, parentName: parentName, profilePicture: UIImage(), babyDOB: babyDOB, email: email)
            
            completionHandler()
        })
    }
    
    func sendToServer() {
        guard let p = profile else { return }
        database.uploadJSON(p.json(), requestType: .profile)
    }
}
