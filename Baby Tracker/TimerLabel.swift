//
//  TimerLabel.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/14/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class TimerLabel: UILabel {

    private let timeInterval:Double = 1
    private var timer:Timer?
    var isPaused = false
    var isRunning = false
    private var counter:Double = 0 {
        didSet {
            let hours = counter.stringFromSecondsToHours(zeroPadding: true)
            let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: true)
            let seconds = minutes.remainder.stringFromSecondsToSeconds(zeroPadding: true)
            
            text = hours.string + ":" + minutes.string + ":" + seconds.string
        }
    }
    
    override init(frame:CGRect) {
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
        setTime(time: 0)
    }
    
    func setTime(time:Double) {
        guard timer == nil else { return }
        counter = time
    }
    
    func currentTime() -> TimeInterval {
        return counter
    }

    func start(startingAt startTime:Double? = nil) {
        guard timer == nil else { return }
        isRunning = true
        
        if let st = startTime {
            counter = st
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self] _ in
            guard let strongSelf = self, !strongSelf.isPaused else { return }
            strongSelf.counter += strongSelf.timeInterval
        })
    }
    
    func end() {
        guard let t = timer else { return }
        isRunning = false
        isPaused = false
        clearPauseAnimation()
        t.invalidate()
        timer = nil
    }
    
    func pause() {
        guard timer != nil else { return }
        isPaused = true
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .curveEaseInOut, .repeat], animations: { _ in
            self.alpha = 0.0
        }, completion: nil)
    }
    
    func resume() {
        guard timer != nil else { return }
        isPaused = false
        clearPauseAnimation()
    }
    
    private func clearPauseAnimation() {
        layer.removeAllAnimations()
        alpha = 1.0
    }
}
