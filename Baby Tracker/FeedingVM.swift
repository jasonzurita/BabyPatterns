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
    
    func loadData(completionHandler:@escaping (Void) -> Void) {
        
        database.configureDatabase(requestType: .nursing, responseHandler: { jsonArray in
            for json in jsonArray {
                self.nursing.processNewNursing(json: json)
            }
            completionHandler()
        })
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        return nursing.timeSinceLastFeeding()
    }
    
    func lastFeedingSide() -> FeedingSide {
        return nursing.lastFeedingSide()
    }
}
