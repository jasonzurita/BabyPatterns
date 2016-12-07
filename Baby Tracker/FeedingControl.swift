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
        didSet { resetLabel() }
    }
    var feedingType:FeedingType = .nursing
    var delegate:FeedingControlDelegate?
    
    private var timer:Timer?
    private var counter = 0 {
        didSet {
            label.text = "00:0\(counter)"
        }
    }
    
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
    
    private func resetLabel() {
        label.text = feedingSide == .left ? "Left" : "Right"
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if !isFeeding {
            button.setTitle("◼︎", for: .normal)
            startTimer()
        } else {
            button.setTitle("▶", for: .normal)
            endTimer()
        }
        isFeeding = !isFeeding
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.count), userInfo: nil, repeats: true)
        counter = 0
    }
    
    func count() {
        counter += 1
    }
    
    private func endTimer() {
        counter = 0
        timer?.invalidate()
        timer = nil
        resetLabel()
    }
}
