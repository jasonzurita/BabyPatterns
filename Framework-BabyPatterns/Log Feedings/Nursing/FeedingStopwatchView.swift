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

public final class FeedingStopwatchView: UIView {

    typealias StatusChangeHandler = ((FeedingType, FeedingSide) -> Void)
    var onStart: StatusChangeHandler?
    var onEnd: StatusChangeHandler?
    var onPause: StatusChangeHandler?
    var onResume: StatusChangeHandler?

    private let _feedingType: FeedingType
    private var _sideInProgress: FeedingSide = .none

    private var _activeControl: FeedingControl? {
        switch (leftFeedingControl.isActive, rightFeedingControl.isActive) {
        case (true, false):
            return leftFeedingControl
        case (false, true):
            return rightFeedingControl
        case (true, true):
            assertionFailure("Both feeding controls are active. How!?")
            return nil
        case (false, false):
            return nil
        }
    }

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

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    @IBAction func feedingButtonPressed(_ sender: FeedingControl) {
        guard sender.side != .none else {
            preconditionFailure("Cannot start / end feeding because no feeding type or no side")
        }

        // TODO: make into enum
        let shouldStartTimer = !timerLabel.isRunning && !timerLabel.isPaused
        let shouldPauseTimer = timerLabel.isRunning && !timerLabel.isPaused && sender.isActive
        let shouldResumeTimer = timerLabel.isRunning && timerLabel.isPaused && sender.isActive

        if shouldStartTimer {
            startFeeding(at: 0, on: sender.side)
            onStart?(_feedingType, sender.side)
        } else if shouldPauseTimer {
            pause()
            onPause?(_feedingType, sender.side)
        } else if shouldResumeTimer {
            resumeFeeding(control: sender)
            onResume?(_feedingType, sender.side)
        }
    }

    func startFeeding(at startTime: TimeInterval, on side: FeedingSide) {
        var control: FeedingControl?
        switch side {
        case .left:
            control = leftFeedingControl
        case .right:
            control = rightFeedingControl
        case .none:
            assertionFailure("Asked to start a feeding on side of = none")
        }
        timerLabel.start(startingAt: startTime)
        control!.setTitle("Pause", for: .normal)
        control!.isActive = true
        stopButton.isHidden = false
        _sideInProgress = control!.side
    }

    func pause() {
        guard let control = _activeControl else { return }
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

        guard _sideInProgress != .none else {
            preconditionFailure("No side in progress to stop")
        }

        // TODO: fix this "!"
        var control: FeedingControl!
        if leftFeedingControl.isActive && _sideInProgress == .left {
            control = leftFeedingControl
        } else if rightFeedingControl.isActive && _sideInProgress == .right {
            control = rightFeedingControl
        } else {
            assertionFailure("Failed to end feeding")
        }
        reset(control: control)
        onEnd?(_feedingType, _sideInProgress)
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
