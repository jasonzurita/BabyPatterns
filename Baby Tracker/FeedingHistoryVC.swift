//
//  FeedingHistoryVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/27/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

final class FeedingHistoryVC: UIViewController, Loggable {

    private enum TimeWindow: TimeInterval {
        case day = 86_400 //in seconds
        case week = 604_800 //in seconds
        case month = 2_592_000 //in seconds
    }

    let shouldPrintDebugLog = true
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var description: String {
        return "\(type(of:self))"
    }

    private var notificationToken: NSObjectProtocol?

    private var screenTimeWindow: TimeWindow = .day {
        didSet {
            setupGraph()
        }
    }
    private let screenHeight = UIScreen.main.bounds.size.width
    private let screenWidth = UIScreen.main.bounds.size.height
    private var barGraphHeight: CGFloat {
        return screenHeight * 0.5
    }
    private let barGraphYOffset: CGFloat = 10
    private let barGraphElementWidth: CGFloat = 6

    private var pointsPerSecond: CGFloat {
        return screenWidth / CGFloat(screenTimeWindow.rawValue)
    }

    weak var feedingsVM: FeedingsVM?

    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGraph()
    }

    private func setupGraph() {
        guard let feedingEvents = feedingsVM?.feedings(withTypes: [.nursing, .bottle, .pumping],
                                                       isFinished: true) else {
            log("no feedings to show...", object: self, type: .warning)
            return }

        let graphWindow = feedingWindow(endDate:feedingEvents.first?.endDate)
        adjustScrollViewContentSize(width: CGFloat(abs(graphWindow.start.timeIntervalSinceNow)) * pointsPerSecond)
        layoutFeedings(feedingEvents, inWindow: graphWindow)
        adjustScrollViewContentOffset()
    }
    //Should be a little over the last feeding to allow showing of the last feeding
    private func feedingWindow(endDate: Date?) -> DateInterval {
        let now = Date() //when? now! when now? now now!
        let past = endDate ?? Date(timeInterval: -(screenTimeWindow.rawValue), since: now)
        return DateInterval(start: past, end: now)
    }

    private func adjustScrollViewContentSize(width: CGFloat) {
        scrollView.contentSize = CGSize(width: width, height: scrollView.contentSize.height)
    }

    private func layoutFeedings(_ feedings: [Feeding], inWindow window: DateInterval) {
        for feeding in feedings {
            guard let endDate = feeding.endDate else {
                let message = "We should only have finished feedings, but feeding not finished. Cannot display..."
                log(message, object: self, type: .error)
                return
            }
            let x = xFeedingLocation(forDate: endDate, inWindow: window)
            let frame = CGRect(x: x,
                               y: screenHeight - (barGraphHeight + barGraphYOffset),
                               width: barGraphElementWidth,
                               height: barGraphHeight)

            let graphElement = BarGraphLollipop(frame: frame)

            scrollView.addSubview(graphElement)
        }
    }

    private func xFeedingLocation(forDate date: Date, inWindow window: DateInterval) -> CGFloat {
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
        notificationToken = center.addObserver(forName: .UIDeviceOrientationDidChange,
                                               object: nil,
                                               queue: nil,
                                               using: { _ in
            if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
                self.performSegue(withIdentifier: K.Segues.UnwindToFeedingVC, sender: nil)
                UIDevice.current.endGeneratingDeviceOrientationNotifications()
                center.removeObserver(self.notificationToken!)
            }
        })
    }

    @IBAction func exitHistoryButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.Segues.UnwindToFeedingVC, sender: nil)
    }

    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            screenTimeWindow = .day
        case 1:
            screenTimeWindow = .week
        case 2:
            screenTimeWindow = .month
        default:
            fatalError("Impossible segement selected...")
        }
    }
}
