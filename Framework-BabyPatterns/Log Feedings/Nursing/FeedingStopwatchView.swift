//
//  FeedingStopwatchView.swift
//  Framework-BabyPatterns
//
//  Created by Jason Zurita on 12/5/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit
import Library

public protocol FeedingStopwatchDataSource: class {
    func currentFeedingDuration() -> TimeInterval?
}

public protocol FeedingStopWatchDelegate: class {
    func start(feeding type: FeedingType, side: FeedingSide)
    func end(feeding type: FeedingType, side: FeedingSide)
    func pause(feeeding type: FeedingType, side: FeedingSide)
    func resume(feeding type: FeedingType, side: FeedingSide)
}

public final class FeedingStopwatchView: UIView {

    private let _feedingType: FeedingType
    private var sideInProgress: FeedingSide = .none

    weak var delegate: FeedingStopWatchDelegate?
    weak var dataSource: FeedingStopwatchDataSource?

    @IBOutlet var view: UIView! {
        didSet {
            view.frame = bounds
            addSubview(view)
        }
    }

    @IBOutlet weak var timerLabel: TimerLabel! {
        didSet {
            timerLabel.dataSource = self
            timerLabel.changeDisplayTime(time: 0)
        }
    }

    @IBOutlet weak var leftFeedingControl: FeedingControl! {
        didSet {
            leftFeedingControl.side = .left
        }
    }

    @IBOutlet weak var rightFeedingControl: FeedingControl! {
        didSet {
            rightFeedingControl.side = .right
        }
    }

    @IBOutlet weak var stopButton: UIButton!

    public init(feedingType: FeedingType, frame: CGRect = .zero) {
        _feedingType = feedingType

        super.init(frame: frame)
        loadNib()

        stopButton.isHidden = true
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBAction func feedingButtonPressed(_ sender: FeedingControl) {
        guard sender.side != .none else {
            preconditionFailure("Cannot start / end feeding because no feeding type or no side")
        }

        // TODO: make into enum
        let shouldStartTimer = !timerLabel.isRunning && !timerLabel.isPaused
        let shouldPauseTimer = timerLabel.isRunning && !timerLabel.isPaused && sender.isActive
        let shouldResumeTimer = timerLabel.isRunning && timerLabel.isPaused && sender.isActive

        if shouldStartTimer {
            startFeeding(control: sender, startTime: 0)
            delegate?.start(feeding: _feedingType, side: sender.side)
        } else if shouldPauseTimer {
            pauseFeeding(control: sender)
            delegate?.pause(feeeding: _feedingType, side: sender.side)
        } else if shouldResumeTimer {
            resumeFeeding(control: sender)
            delegate?.resume(feeding: _feedingType, side: sender.side)
        }
    }

    private func startFeeding(control: FeedingControl, startTime: TimeInterval) {
        timerLabel.start(startingAt: startTime)
        control.setTitle("Pause", for: .normal)
        control.isActive = true
        stopButton.isHidden = false
        sideInProgress = control.side
    }

    private func pauseFeeding(control: FeedingControl) {
        timerLabel.pause()
        control.setTitle("Resume", for: .normal)
    }

    private func resumeFeeding(control: FeedingControl) {
        timerLabel.resume()
        control.setTitle("Pause", for: .normal)
    }

    @IBAction func stopButtonPressed(_: UIButton) {
        guard timerLabel.isRunning else {
            preconditionFailure("Cannot stop timer that is not running")
        }

        guard sideInProgress != .none else {
            preconditionFailure("No side in progress to stop")
        }

        // TODO: fix this "!"
        var control: FeedingControl!
        if leftFeedingControl.isActive && sideInProgress == .left {
            control = leftFeedingControl
        } else if rightFeedingControl.isActive && sideInProgress == .right {
            control = rightFeedingControl
        } else {
            assertionFailure("Failed to end feeding")
        }
        reset(control: control)
        delegate?.end(feeding: _feedingType, side: sideInProgress)
    }

    private func reset(control: FeedingControl) {
        control.isActive = false
        stopButton.isHidden = true
        timerLabel.end()
    }
}

extension FeedingStopwatchView: TimerLabelDataSource {
    public func timeValue(for timerLabel: TimerLabel) -> TimeInterval {
        return dataSource?.currentFeedingDuration() ?? 0.0
    }
}
