//
//  Profile.swift
//  BabyPatterns
//
//  Created by Jason Zurita on 11/7/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit
import Framework_BabyPatterns

struct Profile {
    var babyName: String
    var parentName: String
    var babyDOB: Date
    var email: String
    let userID: String
    var serverKey: String?
    var desiredMaxSupply: Double
    var profilePicture: UIImage?

    init(babyName: String,
         parentName: String,
         babyDOB: Date,
         email: String,
         userID: String,
         serverKey: String? = nil,
         desiredMaxSupply: Double,
         profilePicture: UIImage? = nil) {

        self.babyName = babyName
        self.parentName = parentName
        self.profilePicture = profilePicture
        self.babyDOB = babyDOB
        self.email = email
        self.userID = userID
        self.serverKey = serverKey
        self.desiredMaxSupply = desiredMaxSupply
    }

    func json() -> [String: Any] {
        return [
            K.JsonFields.BabyName: babyName,
            K.JsonFields.ParentName: parentName,
            K.JsonFields.BabyDOB: babyDOB.timeIntervalSince1970,
            K.JsonFields.Email: email,
            K.JsonFields.UserID: userID,
            K.JsonFields.DesiredMaxSupply: desiredMaxSupply,
        ]
    }
}
