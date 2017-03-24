//
//  ProfileVM.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 2/22/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

class ProfileVM {
    private let shouldPrintDebugString = true
    
    //TODO: consider returning a URL to use Data methods instead of having to cast to NSData
    private var profileImageURLPath:String? {
        guard let userID = profile?.userID else { return nil }
        let path = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/user/profilePhoto/"
        if (!FileManager.default.fileExists(atPath: path)) {
            try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        return path + userID
    }
    
    var profile:Profile?
    
    func loadProfile(completionHandler:@escaping (Void) -> Void) {
        DatabaseFacade().configureDatabase(requestType: .profile, responseHandler: { responseArray in
            //TODO: respond with completion handler if this fails
            guard let data = responseArray.last else { completionHandler(); return }
            guard let babyName = data.json[K.JsonFields.BabyName] as? String else { completionHandler(); return  }
            guard let parentName = data.json[K.JsonFields.ParentName] as? String else { completionHandler(); return  }
            guard let email = data.json[K.JsonFields.Email] as? String else { completionHandler(); return  }
            guard let userID = data.json[K.JsonFields.UserID] as? String else { completionHandler(); return }
            guard let babyDOB = Date(timeInterval: data.json[K.JsonFields.BabyDOB]) else { completionHandler(); return  }
            
            self.profile = Profile(babyName: babyName, parentName: parentName, babyDOB: babyDOB, email: email, userID:userID, serverKey: data.serverKey)
            
            guard let imagePath = self.profileImageURLPath, FileManager.default.fileExists(atPath: imagePath) else { completionHandler(); return }
            guard let imageData = NSData(contentsOfFile: imagePath), let image = UIImage(data: imageData as Data) else { completionHandler(); return }
            
            self.profile?.profilePicture = image
            
            completionHandler()
        })
        
//        StorageFacade().download(requestType: .profilePhoto, callback: { (data, error) in
//            guard let data = data else {
//                if let e = error {
//                    Logger.log(message: e.localizedDescription, object: self, type: .error, shouldPrintDebugLog: self.shouldPrintDebugString)
//                }
//                return
//            }
//            if let image = UIImage(data: data) {
//                self.profile?.profilePicture = image
//            }
//        })
    }
    
    func updateProfilePhoto(image:UIImage) {
        profile?.profilePicture = image
        let data = UIImagePNGRepresentation(image)
        StorageFacade().uploadData(data: data!, requestType: .profilePhoto)

        guard let d = data, let path = profileImageURLPath else { return }
        (d as NSData).write(toFile: path, atomically: false)
    }
    
    func sendToServer() {
        guard let p = profile else {
            Logger.log(message: "No profile to send to server...", object: self, type: .warning, shouldPrintDebugLog: shouldPrintDebugString)
            return
        }
        profile?.serverKey = DatabaseFacade().uploadJSON(p.json(), requestType: .profile)
    }
    
    func profileUpdated() {
        guard let p = profile, let serverKey = p.serverKey else {
            Logger.log(message: "Couldn't update profile. Either no profile or no server key...", object: self, type: .error, shouldPrintDebugLog: shouldPrintDebugString)
            return }
        DatabaseFacade().updateJSON(p.json(), serverKey: serverKey, requestType: .profile)
    }
}
