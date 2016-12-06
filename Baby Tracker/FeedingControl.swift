//
//  FeedingControl.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/6/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

protocol FeedingControlDelegate:NSObjectProtocol {
    func feedingStarted(forFeedingControl control:FeedingControl)
    func feedingEnded(forFeedingControl control:FeedingControl)
}

class FeedingControl: UIView {
    
    private var isFeeding = false
    var feedingSide:FeedingSide = .left {
        didSet { label.text = feedingSide == .left ? "Left" : "Right" }
    }
    var feedingType:FeedingType = .nursing
    var delegate:FeedingControlDelegate?
        
    private var counter = 0
    private var timer:Timer?
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed(String(describing: type(of:self)), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed(String(describing: type(of:self)), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }
    
    func configure(side:FeedingSide, type:FeedingType) {
        feedingSide = side
        feedingType = type
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if !isFeeding {
            button.setTitle("◼︎", for: .normal)
        } else {
            button.setTitle("▶", for: .normal)
        }
        isFeeding = !isFeeding
    }
    
    //    private func startTimer(timer:inout Timer?, userInfo:(label:UILabel, counter:Int)) {
    //        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.countdown), userInfo: userInfo, repeats: true)
    //    }
    
    //    func countdown(userInfo:Any?) {
    //        countdownTimerCounter -= 1
    //
    //        if countdownTimerCounter > 0 && countdownTimerCounter < 10 {
    //            auxStatusLabel.text = "00:0\(countdownTimerCounter)"
    //        } else {
    //            auxStatusLabel.text = "00:\(countdownTimerCounter)"
    //        }
    //
    //        if countdownTimerCounter <= 0 {
    //            endCountdownTimer()
    //            updateUserInterfaceForFailedToFindSensor()
    //        }
    //    }
    //
    //    private func endCountdownTimer(timer: inout Timer?, ) {
    //
    //
    //        if let timer = countdownTimer {
    //            countdownTimerCounter = 0
    //            timer.invalidate()
    //            countdownTimer = nil
    //        } else {
    //            printString("No timer to end...")
    //        }
    //    }

}
