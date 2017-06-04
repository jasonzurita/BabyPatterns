//
//  TimerLabel.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/14/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

protocol TimerLabelDataSource: class {
    func timerValueForTimerLabel(timerLabel: TimerLabel) -> TimeInterval
}

class TimerLabel: UILabel {

    weak var dataSource: TimerLabelDataSource?

    private let countingInterval: Double = 1
    private var _timer: Timer?
    var isPaused = false
    var isRunning = false
    private var counter: TimeInterval = 0 {
        didSet {
            let hours = counter.stringFromSecondsToHours(zeroPadding: true)
            let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: true)
            let seconds = minutes.remainder.stringFromSecondsToSeconds(zeroPadding: true)

            text = hours.string + ":" + minutes.string + ":" + seconds.string
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }

    private func setupLabel() {
        backgroundColor = UIColor.clear
        textAlignment = .center
        font = UIFont(name: "Helvetica", size: 49)
        textColor = UIColor.gray
    }

    func changeDisplayTime(time: TimeInterval) {
        guard !isRunning else { return }
        counter = time
    }

    func start(startingAt startTime: TimeInterval? = nil) {
        guard _timer == nil else { return }
        isRunning = true

        counter = startingCounterTime(startTime:startTime)

        _timer = Timer.scheduledTimer(withTimeInterval: countingInterval, repeats: true, block: { [weak self] _ in
            guard let strongSelf = self else { return }
            guard !strongSelf.isPaused else {
                strongSelf.pulseAnimationIfNotPulsing()
                return
            }
            strongSelf.counter += 1
        })
    }

    private func startingCounterTime(startTime: TimeInterval?) -> TimeInterval {
        var returnValue: TimeInterval = 0
        if let st = startTime {
            returnValue = st
        } else if let ds = dataSource {
            returnValue = ds.timerValueForTimerLabel(timerLabel: self)
        }

        return returnValue
    }

    func end() {
        guard let t = _timer else { return }
        isRunning = false
        isPaused = false
        clearPauseAnimation()
        t.invalidate()
        _timer = nil
        changeDisplayTime(time: 0)
    }

    func pause() {
        guard _timer != nil else { return }
        isPaused = true
        pulseAnimationIfNotPulsing()
    }

    private func pulseAnimationIfNotPulsing() {
        guard layer.animationKeys() == nil else { return }
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.autoreverse, .curveEaseInOut, .repeat],
                       animations: { _ in
            self.alpha = 0.0
        }, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.alpha = 1.0
        })
    }

    func resume() {
        guard _timer != nil else { return }
        isPaused = false
        clearPauseAnimation()
    }

    private func clearPauseAnimation() {
        layer.removeAllAnimations()
    }

    deinit {
        _timer?.invalidate()
    }
}
