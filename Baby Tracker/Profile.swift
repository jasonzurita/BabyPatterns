//
//  Profile.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/7/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation
import UIKit

struct Profile {
    let babyName:String
    let parentName:String
    let profilePicture:UIImage
    let babyDOB:Date
    let email:String
    
    static func loadProfile(completionHandler:@escaping (Profile) -> Void) {
        FirebaseFacade().configureDatabase(requestType: .profile, responseHandler: { responseArray in
            //TODO: respond with completion handler if this fails
            guard let profile = responseArray.last?.json else { return }
            guard let bName = profile[K.JsonFields.BabyName] as? String else { return }
            guard let pName = profile[K.JsonFields.ParentName] as? String else { return }
            guard let email = profile[K.JsonFields.Email] as? String else { return }
//            guard let bday = Date(timeInterval: profile["babyDOB"]) else { return }
            
            completionHandler(Profile(babyName: bName, parentName: pName, profilePicture: UIImage(), babyDOB: Date(), email:email))
        })
    }
    
    func json() -> [String:Any] {
        return [K.JsonFields.BabyName:babyName,
                K.JsonFields.ParentName:parentName,
                K.JsonFields.BabyDOB:babyDOB.timeIntervalSince1970,
                K.JsonFields.Email:email]
    }
}
