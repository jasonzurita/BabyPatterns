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
    private var isPaused = false
    private var counter:Double = 0 {
        didSet {
            let hours = counter.stringFromSecondsToHours()
            let minutes = hours.remainder.stringFromSecondsToMinutes()
            let seconds = minutes.remainder.stringFromSecondsToSeconds()
            
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
        font = UIFont(name: "Helvetica", size: 42)
        textColor = UIColor.gray
        setStartTime(time: 0)
    }
    
    func setStartTime(time:Double) {
        guard timer == nil else { return }
        counter = time
    }

    func start() {
        guard timer == nil else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self] _ in
            guard let strongSelf = self, !strongSelf.isPaused else { return }
            strongSelf.counter += strongSelf.timeInterval
        })
    }
    
    func end() {
        guard let t = timer else { return }
        counter = 0
        t.invalidate()
        timer = nil
    }
    
    func pause() {
        guard timer != nil else { return }
        isPaused = true
    }
    
    func resume() {
        guard timer != nil else { return }
        isPaused = false
    }

}
