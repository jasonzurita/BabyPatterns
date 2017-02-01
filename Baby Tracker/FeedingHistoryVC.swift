//
//  FeedingHistoryVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/27/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingHistoryVC: UIViewController {
    
    weak var feedings:FeedingVM?
    
    @IBOutlet weak var scrollView: UIScrollView!
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var description: String {
        return "\(type(of:self))"
    }
    
    private var notificationToken:NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let feedings = feedings?.feedingsMatching(type: .nursing, isFinished: true) else { return }
        loadFeedings(feedings:feedings)
    }
    
    private func loadFeedings(feedings:[Feeding]) {
        let now = Date() //when? now! when now? now now!
        let past = Date(timeInterval: -(24 * 60 * 60), since: now)
        let window = DateInterval(start: past, end: now)
        
        let screenHeight = UIScreen.main.bounds.size.width
        let barGraphHeight = screenHeight * 0.5
        
        for feeding in feedings {
            guard let endDate = feeding.endDate else { return }
            let x = xLocation(forDate: endDate, inWindow: window)
            let frame = CGRect(x: x, y: screenHeight - (barGraphHeight + 10), width: 8, height: barGraphHeight)
            let graphElement = BarGraphLollipop(frame: frame)
            scrollView.addSubview(graphElement)
        }
    }
    
    private func xLocation(forDate date:Date, inWindow window:DateInterval) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.height

        let pointsPerSecond = screenWidth / CGFloat(window.duration)
        let secondsSinceNow = abs(date.timeIntervalSince(window.end))
        
        return pointsPerSecond * CGFloat(secondsSinceNow)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        let center = NotificationCenter.default
        notificationToken = center.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil, using: { _ in
            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
                self.performSegue(withIdentifier: K.Segues.UnwindToFeedingVCSegue, sender: nil)
                UIDevice.current.endGeneratingDeviceOrientationNotifications()
                center.removeObserver(self.notificationToken!)
            }

        })
    }
}
