//
//  FeedingsVM.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/8/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import Foundation

class FeedingsVM: Loggable {
    let shouldPrintDebugLog = true
    var feedings: [Feeding] = []

    func loadFeedings(completionHandler: @escaping (Void) -> Void) {

        DatabaseFacade().configureDatabase(requestType: .feedings, responseHandler: { responseArray in
            for response in responseArray {
                self.newPotentialFeeding(json: response.json, serverKey:response.serverKey)
            }
            completionHandler()
        })
    }

    func newPotentialFeeding(json: [String:Any], serverKey: String) {
        guard let feeding = Feeding(json: json, serverKey: serverKey) else { return }
        feedings.append(feeding)
    }
}
