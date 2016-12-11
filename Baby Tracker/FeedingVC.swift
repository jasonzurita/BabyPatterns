//
//  FeedingVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/3/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingVC: UIViewController {
    
    var feedings:FeedingFacade!
    
    @IBOutlet weak var nursingLeftControl: FeedingControl!
    @IBOutlet weak var nursingRightControl: FeedingControl!
    
    @IBOutlet weak var controlBar: SegmentedControlBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titles = FeedingType.allValues.map { $0.rawValue }
        controlBar.configureSegmentedBar(titles: titles, defaultSegmentIndex:0, delegate: self)
//
//        nursingLeftControl.configure(side: .left, type: .nursing)
//        nursingLeftControl.delegate = self
//        
//        nursingRightControl.configure(side: .right, type: .nursing)
//        nursingRightControl.delegate = self
    }
}

extension FeedingVC: FeedingControlDelegate {
    func feedingStarted(forFeedingControl control: FeedingControl) {
        feedings.feedingStarted(type: control.feedingType, start: Date(), side: control.feedingSide)
    }
    
    func feedingEnded(forFeedingControl control: FeedingControl) {
        feedings.feedingEnded(type: control.feedingType, side: control.feedingSide)
    }
}

extension FeedingVC: SegmentedControlBarDelegate {
    func segmentedControlBar(bar: SegmentedControlBar, segmentWasTapped index: Int) {
        print("Segment tapped: \(index)")
    }
}
