//
//  FeedingFacadeVM.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/8/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingFacadeVM: BaseVM {
    let feedingVM = FeedingVM()
    let feedingsInProgressVM = FeedingsInProgressVM()
    
    func loadData(completionHandler:@escaping (Void) -> Void) {
        
        database.configureDatabase(requestType: .nursing, responseHandler: { responseArray in
            for response in responseArray {
                self.feedingVM.newPotentialFeeding(json: response.data, serverKey:response.serverKey)
                self.feedingsInProgressVM.newPotentialFeeding(json: response.data, serverKey:response.serverKey)
            }
            completionHandler()
        })
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        return feedingVM.timeSinceLastFeeding()
    }
    
    func lastFeedingSide() -> FeedingSide {
        return feedingVM.lastFeedingSide()
    }
}
