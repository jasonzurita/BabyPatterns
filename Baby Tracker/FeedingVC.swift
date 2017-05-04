//
//  FeedingVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/3/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

protocol FeedingInProgressDelegate:NSObjectProtocol {
    func feedingStarted(type:FeedingType, side:FeedingSide)
    func feedingEnded(type:FeedingType, side:FeedingSide)
    func updateFeedingInProgress(type:FeedingType, side:FeedingSide, isPaused:Bool)
}

protocol BottleFeedingDelegate:NSObjectProtocol {
    func logBottleFeeding(withAmount amount:Double, time:Date)
}

protocol FeedingsDataSource:NSObjectProtocol {
    func lastFeeding(type:FeedingType) -> Feeding?
    func remainingSupply() -> Double
}

class FeedingVC: UIViewController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //properties
    weak var feedingsVM:FeedingsVM?
    var profileVM:ProfileVM?
    private var notificationToken:NSObjectProtocol?
    
    //outlets
    @IBOutlet weak var segmentedControl: SegmentedControlBar!
    @IBOutlet weak var profileView: ProfileView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let titles = FeedingType.allValues.map { $0.rawValue }
        segmentedControl.configureSegmentedBar(titles: titles, defaultSegmentIndex:0)
        
        updateProfileUI()
    }
    
    private func updateProfileUI() {
        guard let p = profileVM?.profile else { return }
        profileView.nameLabel.text = p.babyName
        profileView.imageView.image = p.profilePicture
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
            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                    self.performSegue(withIdentifier: K.Segues.FeedingHistorySegue, sender: nil)
                    UIDevice.current.endGeneratingDeviceOrientationNotifications()
                    center.removeObserver(self.notificationToken!)
            }
        })
    }
    
    @IBAction func showHistoryButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: K.Segues.FeedingHistorySegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //equip page view controller to function here
        if let vc = segue.destination as? FeedingPageVC {
            configureFeedingPageVC(vc: vc)
        } else if let vc = segue.destination as? FeedingHistoryVC {
            configureFeedingHistoryVC(vc:vc)
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
        page3.delegate = self
        page3.dataSource = self
        vc.pages.append(contentsOf: [page1, page2, page3])
    }
    
    private func configureFeedingHistoryVC(vc:FeedingHistoryVC) {
        vc.feedingsVM = feedingsVM
    }
    
    @IBAction func unwindToFeedingVC(segue: UIStoryboardSegue) {

    }
}

extension FeedingVC: FeedingInProgressDelegate {
    
    func feedingStarted(type:FeedingType, side:FeedingSide) {
        feedingsVM?.feedingStarted(type: type, side: side)
    }
    
    func feedingEnded(type:FeedingType, side:FeedingSide) {
        feedingsVM?.feedingEnded(type: type, side: side)
        showFeedingSavedToast()
    }
    
    func updateFeedingInProgress(type: FeedingType, side: FeedingSide, isPaused: Bool) {
        feedingsVM?.updateFeedingInProgress(type: type, side: side, isPaused: isPaused)
    }
    
    private func showFeedingSavedToast() {
        let toastSize:CGFloat = 150
        let frame = CGRect(x: self.view.frame.width * 0.5 - (toastSize * 0.5), y: self.view.frame.height * 0.5 - (toastSize * 0.5), width: toastSize, height: toastSize)
        let toast = Toast(frame: frame, text: "Saved!")
        toast.presentInView(view: self.view)
    }
}

extension FeedingVC: FeedingsDataSource {
    func lastFeeding(type: FeedingType) -> Feeding? {
        return feedingsVM?.lastFeeding(type: type)
    }
    
    func remainingSupply() -> Double {
        return feedingsVM?.remainingSupply() ?? 0.0
    }
}

extension FeedingVC: BottleFeedingDelegate {
    func logBottleFeeding(withAmount amount: Double, time: Date) {
        //TODO
    }
}
