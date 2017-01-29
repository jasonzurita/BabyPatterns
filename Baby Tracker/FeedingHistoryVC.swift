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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.green
        // Do any additional setup after loading the view.
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
