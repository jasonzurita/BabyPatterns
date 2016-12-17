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
        
        func setupInitialState() {
            leftFeedingControl.side = .left
            rightFeedingControl.side = .right
            stopTimerButton.isHidden = true
        }
        
        setupInitialState()
        resumeFeedingIfNeeded()
    }
    
    private func resumeFeedingIfNeeded() {
        guard let type = feedingType else { return }

        if let feeding = dataSource?.feedingInProgress(type: type, side: .left) {
            resumeInProgressFeeding(control: leftFeedingControl, feeding: feeding)
        } else if let feeding = dataSource?.feedingInProgress(type: type, side: .right) {
            resumeInProgressFeeding(control: rightFeedingControl, feeding: feeding)
        }
    }
    
    private func resumeInProgressFeeding(control:FeedingControl, feeding:FeedingTimer) {
        startFeeding(control: control, startTime:feeding.duration)
        
        if feeding.isPaused {
            pauseFeeding(control: control)
        } else {
            resumeFeeding(control: control)
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
            startFeeding(control: sender, startTime: 0)
            delegate?.feedingStarted(type: type, side: sender.side)
        } else if shouldPauseTimer {
            pauseFeeding(control: sender)
        } else if shouldResumeTimer {
            resumeFeeding(control: sender)
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        guard timerLabel.isRunning, let type = feedingType else {
            assertionFailure("Cannot stop timer that is not running")
            return
        }
        
        guard sideInProgress != .none else {
            return
        }

        var control = FeedingControl()
        if leftFeedingControl.isActive && sideInProgress == .left {
            control = leftFeedingControl
        } else if rightFeedingControl.isActive && sideInProgress == .right {
            control = rightFeedingControl
        } else {
            assertionFailure("Failed to end feeding")
        }
        endFeeding(control: control)
    
        delegate?.feedingEnded(type: type, side: sideInProgress, duration: timerLabel.currentTime())
    }
    
    private func startFeeding(control:FeedingControl, startTime:TimeInterval) {
        timerLabel.start(startingAt: startTime)
        control.setTitle("Pause", for: .normal)
        control.isActive = true
        stopTimerButton.isHidden = false
        sideInProgress = control.side
    }
    
    private func pauseFeeding(control:FeedingControl) {
        timerLabel.pause()
        control.setTitle("Resume", for: .normal)
    }
    
    private func resumeFeeding(control:FeedingControl) {
        timerLabel.resume()
        control.setTitle("Pause", for: .normal)
    }
    
    private func endFeeding(control:FeedingControl) {
        control.isActive = false
        stopTimerButton.isHidden = true
        timerLabel.end()
    }
    
}
