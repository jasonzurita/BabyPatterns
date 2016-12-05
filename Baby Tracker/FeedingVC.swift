//
//  FeedingVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/3/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    var pumpingStartTime:Date?
    @IBAction func pumpingButtonPressed(_ sender: UIButton) {

    }
    
    var nursingStartTime:Date?
    @IBAction func nursingButtonPressed(_ sender: UIButton) {
        if let startTime = nursingStartTime {
            FeedingService.shared.addFeedingEvent(type: .nursing, start: startTime, end: Date(), side: FeedingSide(rawValue: sender.tag))
            sender.setTitle("▶", for: .normal)
        } else {
            nursingStartTime = Date()
            sender.setTitle("◼︎", for: .normal)
        }
    }
}
