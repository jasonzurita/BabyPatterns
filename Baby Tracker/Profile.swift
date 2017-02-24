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
    let serverKey:String?
    
    init(babyName:String, parentName:String, profilePicture:UIImage, babyDOB:Date, email:String, serverKey:String? = nil) {
        self.babyName = babyName
        self.parentName = parentName
        self.profilePicture = profilePicture
        self.babyDOB = babyDOB
        self.email = email
        self.serverKey = serverKey
    }
    
    func json() -> [String:Any] {
        return [K.JsonFields.BabyName:babyName,
                K.JsonFields.ParentName:parentName,
                K.JsonFields.BabyDOB:babyDOB.timeIntervalSince1970,
                K.JsonFields.Email:email]
    }
}
