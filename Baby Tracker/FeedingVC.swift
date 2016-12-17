//
//  FeedingVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/3/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

protocol FeedingTimerDelegate:NSObjectProtocol {
    func feedingStarted(type:FeedingType, side:FeedingSide)
    func feedingEnded(type:FeedingType, side:FeedingSide, duration:TimeInterval)
    func updateFeedingInProgress(type:FeedingType, side:FeedingSide, duration:TimeInterval, isPaused:Bool)
}

protocol FeedingTimerDataSource:NSObjectProtocol {
    func feedingInProgress(type:FeedingType, side:FeedingSide) -> FeedingTimer?
}

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
        page1.delegate = self
        page1.dataSource = self
        let page2 = FeedingTimerVC(nibName: "FeedingTimerVC", bundle: nil)
        page2.feedingType = .pumping
        page2.delegate = self
        page2.dataSource = self
        let page3 = BottleVC(nibName: "BottleVC", bundle: nil)
        page2.feedingType = .bottle
        
        vc.pages.append(contentsOf: [page1, page2, page3])
    }
}

extension FeedingVC: FeedingTimerDelegate {
    
    func feedingStarted(type:FeedingType, side:FeedingSide) {
        feedings.feedingStarted(type: type, side: side)
    }
    
    func feedingEnded(type:FeedingType, side:FeedingSide, duration:TimeInterval) {
    
        showFeedingSavedToast()
        feedings.feedingEnded(type: type, side: side, duration: duration)
    }
    
    func updateFeedingInProgress(type: FeedingType, side: FeedingSide, duration: TimeInterval, isPaused: Bool) {
        feedings.updateFeedingInProgress(type: type, side: side, duration: duration, isPaused: isPaused)
    }
    
    private func showFeedingSavedToast() {
        let toastSize:CGFloat = 150
        let frame = CGRect(x: self.view.frame.width * 0.5 - (toastSize * 0.5), y: self.view.frame.height * 0.5 - (toastSize * 0.5), width: toastSize, height: toastSize)
        let toast = Toast(frame: frame, text: "Saved!")
        toast.presentInView(view: self.view)
    }
}

extension FeedingVC: FeedingTimerDataSource {
    func feedingInProgress(type:FeedingType, side:FeedingSide) -> FeedingTimer? {
        return feedings.feedingInProgress(type: type, side: side)
    }
}

