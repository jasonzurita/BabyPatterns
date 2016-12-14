//
//  FeedingVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/3/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingVC: UIViewController {
    
    //properties
    var feedings:FeedingFacade!
    
    //outlets
    @IBOutlet weak var segmentedControl: SegmentedControlBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        let titles = FeedingType.allValues.map { $0.rawValue }
        segmentedControl.configureSegmentedBar(titles: titles, defaultSegmentIndex:0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //equip page view controller to function here
        if let vc = segue.destination as? FeedingPageVC {
            configureFeedingPageVC(vc: vc)
        }
    }
    
    private func configureFeedingPageVC(vc:FeedingPageVC) {
        segmentedControl.delegate = vc
        vc.segmentedControl = segmentedControl
        
        let page1 = FeedingTimerVC(nibName: "FeedingTimerVC", bundle: nil)
        page1.feedingType = .nursing
        let page2 = FeedingTimerVC(nibName: "FeedingTimerVC", bundle: nil)
        page2.feedingType = .pumping
        let page3 = BottleVC(nibName: "BottleVC", bundle: nil)
        page2.feedingType = .bottle
        
        page2.view.backgroundColor = UIColor.purple
        vc.pages.append(contentsOf: [page1, page2, page3])
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


