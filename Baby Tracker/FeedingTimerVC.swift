//
//  FeedingTimerVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/11/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingTimerVC: UIViewController {
    
    @IBOutlet weak var timerLabel: TimerLabel!
    
    var feedingType:FeedingType?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func feedingButtonPressed(_ sender: CircleButton) {
        sender.isActive = !sender.isActive
        timerLabel.start()
    }
}
