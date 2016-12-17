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
    weak var dataSource:FeedingTimerDataSource?
    
    private var sideInProgress:FeedingSide = .none
    
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
        
        guard let type = feedingType else { return }
        
        if let feeding = dataSource?.feedingInProgress(type: type, side: .left) {
            stopTimerButton.isHidden = false
            timerLabel.setTime(time: feeding.duration)
            timerLabel.start()
            leftFeedingControl.isActive = true
            
            if feeding.isPaused {
                timerLabel.pause()
                leftFeedingControl.setTitle("Resume", for: .normal)
            } else {
                leftFeedingControl.setTitle("Pause", for: .normal)

            }
            return
        }
        
        if let feeding = dataSource?.feedingInProgress(type: type, side: .right) {
            stopTimerButton.isHidden = false
            timerLabel.setTime(time: feeding.duration)
            timerLabel.start()
            leftFeedingControl.isActive = true
            
            if feeding.isPaused {
                timerLabel.pause()
                rightFeedingControl.setTitle("Resume", for: .normal)
            } else {
                rightFeedingControl.setTitle("Pause", for: .normal)
                
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard timerLabel.isRunning, sideInProgress != .none, let type = feedingType else { return }
        
        delegate?.updateFeedingInProgress(type: type, side: sideInProgress, duration: timerLabel.currentTime(), isPaused: timerLabel.isPaused)
        
    }

    @IBAction func feedingButtonPressed(_ sender: FeedingControl) {
        guard let type = feedingType, sender.side != .none else {
            assertionFailure("Cannot start / end feeding because no feeding type or no side")
            return
        }
        
        let shouldStartTimer = !timerLabel.isRunning && !timerLabel.isPaused
        let shouldPauseTimer = timerLabel.isRunning && !timerLabel.isPaused && sender.isActive
        let shouldResumeTimer = timerLabel.isRunning && timerLabel.isPaused && sender.isActive
        
        if  shouldStartTimer {
            timerLabel.start(startingAt: 0)
            sender.setTitle("Pause", for: .normal)
            delegate?.feedingStarted(type: type, side: sender.side)
            sender.isActive = true
            stopTimerButton.isHidden = false
            sideInProgress = sender.side
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
        
        if sideInProgress == .left {
            leftFeedingControl.isActive = false
        } else if sideInProgress == .right {
            rightFeedingControl.isActive = false
        } else {
            assertionFailure("Failed to end feeding for unknown side")
        }
        
        delegate?.feedingEnded(type: type, side: sideInProgress, duration: timerLabel.currentTime())
        
    }
    
    
}
