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
    var feedingType:FeedingType!
    weak var delegate:FeedingInProgressDelegate?
    weak var dataSource:FeedingsDataSource?
    
    private var sideInProgress:FeedingSide = .none
    private let shouldPrintDebugString = true
    
    //outlets
    @IBOutlet weak var timerLabel: TimerLabel!
    @IBOutlet weak var leftFeedingControl: FeedingControl!
    @IBOutlet weak var rightFeedingControl: FeedingControl!
    
    @IBOutlet weak var stopTimerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if feedingType == nil {
            assertionFailure("Feeding type not assigned...")
        }
        
        func setupInitialState() {
            leftFeedingControl.side = .left
            rightFeedingControl.side = .right
            stopTimerButton.isHidden = true
            timerLabel.dataSource = self
        }
        
        setupInitialState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resumeFeedingIfNeeded()
    }

    private func resumeFeedingIfNeeded() {
        guard let lf = dataSource?.lastFeeding(type: feedingType) else { return }
        
        if lf.isFinished {
            showLastFeeding(finishedFeeding:lf)
        } else {
            guard let control = lf.side == .left ? leftFeedingControl : rightFeedingControl else {
                debugPrint(string: "No active control to resume feeding with")
                return
            }
            resumeFeeding(feedingInProgress:lf, activeControl: control)
        }
    }
    
    private func showLastFeeding(finishedFeeding:Feeding) {
        
    }
    
    private func resumeFeeding(feedingInProgress:Feeding, activeControl:FeedingControl) {
        startFeeding(control: activeControl, startTime:feedingInProgress.duration())
        if feedingInProgress.isPaused {
            pauseFeeding(control: activeControl)
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        guard timerLabel.isRunning else {
            assertionFailure("Cannot stop timer that is not running")
            return
        }
        
        guard sideInProgress != .none else {
            assertionFailure("No side in progress to stop")
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
        delegate?.feedingEnded(type: feedingType, side: sideInProgress, duration: timerLabel.currentTime())
    }
    
    fileprivate func updateFeedingInProgress(type:FeedingType, side:FeedingSide) {
        delegate?.updateFeedingInProgress(type: type, side: sideInProgress, isPaused: timerLabel.isPaused)
    }
    
    @IBAction func feedingButtonPressed(_ sender: FeedingControl) {
        guard sender.side != .none else {
            assertionFailure("Cannot start / end feeding because no feeding type or no side")
            return
        }
        
        let shouldStartTimer = !timerLabel.isRunning && !timerLabel.isPaused
        let shouldPauseTimer = timerLabel.isRunning && !timerLabel.isPaused && sender.isActive
        let shouldResumeTimer = timerLabel.isRunning && timerLabel.isPaused && sender.isActive
        
        if  shouldStartTimer {
            startFeeding(control: sender, startTime: 0)
            delegate?.feedingStarted(type: feedingType, side: sender.side)
        } else if shouldPauseTimer {
            pauseFeeding(control: sender)
            updateFeedingInProgress(type: feedingType, side: sender.side)
        } else if shouldResumeTimer {
            resumeFeeding(control: sender)
            updateFeedingInProgress(type: feedingType, side: sender.side)
        }
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
    
    fileprivate func debugPrint(string:String) {
        if shouldPrintDebugString {
            print(String(describing: "-- Debug -- \(type(of:self)): " + string))
        }
    }
}

extension FeedingTimerVC: TimerLabelDataSource {
    func timerValueForTimerLabel(timerLabel: TimerLabel) -> TimeInterval {

        guard let fip = dataSource?.lastFeeding(type: feedingType) else { return 0.0 }
        
        return fip.duration()
    }
}
