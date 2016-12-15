//
//  FeedingTimerVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/11/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit



class FeedingTimerVC: UIViewController {
    
    //properties
    var feedingType:FeedingType?
    weak var delegate:FeedingTimerDelegate?
    
    //outlets
    @IBOutlet weak var timerLabel: TimerLabel!
    @IBOutlet weak var leftFeedingControl: FeedingControl!
    @IBOutlet weak var rightFeedingControl: FeedingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftFeedingControl.side = .left
        rightFeedingControl.side = .right
    }

    @IBAction func feedingButtonPressed(_ sender: FeedingControl) {
        guard let type = feedingType, let side = sender.side else {
            assertionFailure("Cannot start / end feeding because no feeding type or no side")
            return
        }
        
        if sender.isActive {
            timerLabel.end()
            delegate?.feedingEnded(type: type, side: side)
        } else {
            timerLabel.start()
            delegate?.feedingStarted(type: type, side: side)
        }
        
        sender.isActive = !sender.isActive
    }
}
