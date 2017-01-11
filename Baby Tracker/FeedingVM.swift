//
//  feedingVM.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/19/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

class FeedingVM : BaseVM {
    
    let nursing = Nursing()
    //let pumping = Pumping()
    
    func newPotentialFeeding(json:[String:Any], serverKey:String) {
        nursing.newPotentialFeeding(json: json, serverKey: serverKey)
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        return nursing.timeSinceLastFeeding()
    }
    
    func lastFeedingSide() -> FeedingSide {
        return nursing.lastFeedingSide()
    }
}
