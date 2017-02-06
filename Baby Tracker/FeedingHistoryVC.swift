//
//  FeedingHistoryVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/27/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingHistoryVC: UIViewController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var description: String {
        return "\(type(of:self))"
    }
    
    private var notificationToken:NSObjectProtocol?
    private let screenTimeWindowSeconds:TimeInterval = 24 * 60 * 60
    private let screenHeight = UIScreen.main.bounds.size.width
    private let screenWidth = UIScreen.main.bounds.size.height
    private var barGraphHeight:CGFloat {
        return screenHeight * 0.5
    }
    private let barGraphYOffset:CGFloat = 10
    private let barGraphElementWidth:CGFloat = 6
    
    private var pointsPerSecond:CGFloat {
        return screenWidth / CGFloat(screenTimeWindowSeconds)
    }

    weak var feedings:FeedingVM?

    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGraph()
    }
    
    private func setupGraph() {
        guard let allFeedings = feedings?.feedingsMatching(type: .nursing, isFinished: true) else {
            print("no feedings to show...")
            return }

        let fullFeedingsWindow = dateIntervalWindow(endDate:allFeedings.first?.endDate)
        adjustScrollViewContentSize(width: CGFloat(abs(fullFeedingsWindow.start.timeIntervalSinceNow)) * pointsPerSecond)
        layoutFeedings(allFeedings, inWindow: fullFeedingsWindow)
        adjustScrollViewContentOffset()
    }
    
    private func dateIntervalWindow(endDate:Date?) -> DateInterval {
        let now = Date() //when? now! when now? now now!
        let past = endDate ?? Date(timeInterval: -(screenTimeWindowSeconds), since: now)
        return DateInterval(start: past, end: now)
    }
    
    private func adjustScrollViewContentSize(width:CGFloat) {
        scrollView.contentSize = CGSize(width: width, height: scrollView.contentSize.height)
    }
    
    private func layoutFeedings(_ feedings:[Feeding], inWindow window:DateInterval) {
        for feeding in feedings {
            guard let endDate = feeding.endDate else {
                print("Feeding not finished, so cannot display...")
                return
            }
            let x = xFeedingLocation(forDate: endDate, inWindow: window)
            let frame = CGRect(x: x, y: screenHeight - (barGraphHeight + barGraphYOffset), width: barGraphElementWidth, height: barGraphHeight)
            let graphElement = BarGraphLollipop(frame: frame)
            
            scrollView.addSubview(graphElement)
        }
    }
    
    private func xFeedingLocation(forDate date:Date, inWindow window:DateInterval) -> CGFloat {
        let maxX = scrollView.contentSize.width
        let secondsSinceNow = CGFloat(abs(date.timeIntervalSince(window.end)))
        
        return maxX - pointsPerSecond * CGFloat(secondsSinceNow) - barGraphElementWidth
    }
    
    private func adjustScrollViewContentOffset() {
        scrollView.contentOffset = CGPoint(x: scrollView.contentSize.width, y: scrollView.contentOffset.y)
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
