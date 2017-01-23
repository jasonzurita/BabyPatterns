//
//  FeedingVM.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/8/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import Foundation

class FeedingVM: BaseVM {
    
    var feedings:[Feeding] = []
    
    func loadData(completionHandler:@escaping (Void) -> Void) {
        
        database.configureDatabase(requestType: .nursing, responseHandler: { responseArray in
            for response in responseArray {
                self.newPotentialFeeding(json: response.data, serverKey:response.serverKey)
            }
            completionHandler()
        })
    }
    
    func newPotentialFeeding(json:[String:Any], serverKey:String) {
        guard let feeding = Feeding(json: json, serverKey: serverKey) else { return }
        feedings.append(feeding)
    }
}

