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
    
    @IBOutlet weak var stopTimerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leftFeedingControl.side = .left
        rightFeedingControl.side = .right
        stopTimerButton.isHidden = true
    }

    @IBAction func feedingButtonPressed(_ sender: FeedingControl) {
        guard let type = feedingType, let side = sender.side else {
            assertionFailure("Cannot start / end feeding because no feeding type or no side")
            return
        }
        
        let shouldStartTimer = !timerLabel.isRunning && !timerLabel.isPaused
        let shouldPauseTimer = timerLabel.isRunning && !timerLabel.isPaused && sender.isActive
        let shouldResumeTimer = timerLabel.isRunning && timerLabel.isPaused && sender.isActive
        
        if  shouldStartTimer {
            timerLabel.start(startingAt: 0)
            sender.setTitle("Pause", for: .normal)
            delegate?.feedingStarted(type: type, side: side)
            sender.isActive = true
            stopTimerButton.isHidden = false
        } else if shouldPauseTimer {
            timerLabel.pause()
            sender.setTitle("Resume", for: .normal)
        } else if shouldResumeTimer {
            timerLabel.resume()
            sender.setTitle("Pause", for: .normal)
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        guard timerLabel.isRunning, let type = feedingType else {
            assertionFailure("Cannot stop timer that is not running")
            return
        }
    
        sender.isHidden = true
        timerLabel.end()
        
        var side:FeedingSide = .none
        if leftFeedingControl.isActive {
            side = .left
            leftFeedingControl.isActive = false
        } else if rightFeedingControl.isActive {
            side = .right
            rightFeedingControl.isActive = false
        }
        
        delegate?.feedingEnded(type: type, side: side)
        
    }
    
    
}
