//
//  FeedingService.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/2/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingService {

    static let shared = FeedingService()
    
    private let database = FirebaseFacade()
    
    let nursing = Nursing()
    
    init() {
        database.configureDatabase(requestType: .nursings, responseHandler: { json in
            if self.nursing.processNewNursing(json: json) {
            }
        })
    }
    
    func timeSinceLastFeeding() -> TimeInterval {
        return nursing.timeSinceLastFeeding()
    }
}
