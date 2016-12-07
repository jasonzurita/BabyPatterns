//
//  FeedingVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/3/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingVC: UIViewController {
    
    @IBOutlet weak var nursingLeftControl: FeedingControl!
    
    @IBOutlet weak var nursingRightControl: FeedingControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        nursingLeftControl.configure(side: .left, type: .nursing)
        nursingLeftControl.delegate = self
        
        nursingRightControl.configure(side: .right, type: .nursing)
        nursingRightControl.delegate = self
    }
}

extension FeedingVC: FeedingControlDelegate {
    func feedingStarted(forFeedingControl control: FeedingControl) {
        FeedingService.shared.feedingStarted(type: control.feedingType, start: Date(), side: control.feedingSide)
    }
    
    func feedingEnded(forFeedingControl control: FeedingControl) {
        FeedingService.shared.feedingEnded(type: control.feedingType, side: control.feedingSide)
    }
}
