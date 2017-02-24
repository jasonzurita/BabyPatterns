//
//  DispatchVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/15/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit
import FirebaseAuth

class DispatchVC: UIViewController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var feedingsVM:FeedingsVM?
    private var profileVM:ProfileVM?
    
    //TODO: this should be changed to be a bitwise operator
    private var didRequestFeedings = false
    private var didRequestProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let user = FIRAuth.auth()?.currentUser {
            self.userLoggedIn(user: user)
        } else {
            userLoggedOut()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activityIndicator.stopAnimating()
    }
    
    private func userLoggedIn(user:FIRUser?) {
        if let user = user {
            print("User id: \(user.uid)")
        }
        
        loadProfile()
        loadFeedings()
    }
    
    private func loadProfile() {
        let p = ProfileVM()
        profileVM = p
        p.loadProfile(completionHandler: { _ in
            self.didRequestProfile = true
            self.userLoggedIn()
            
        })
    }
    
    private func loadFeedings() {
        let f = FeedingsVM()
        feedingsVM = f
        f.loadFeedings(completionHandler: { _ in
            self.didRequestFeedings = true
            self.userLoggedIn()
        })
    }
    
    private func userLoggedOut() {
        performSegue(withIdentifier: K.Segues.LoggedOutSegue, sender: nil)
    }
    
    private func userLoggedIn() {
        if didRequestFeedings && didRequestProfile {
            performSegue(withIdentifier: K.Segues.LoggedInSegue, sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? UINavigationController, let homeVC = navigationVC.topViewController as? HomeVC {
            homeVC.feedingsVM = feedingsVM
            homeVC.profileVM = profileVM
            feedingsVM = nil
            profileVM = nil
            didRequestProfile = false
            didRequestFeedings = false
        }
    }
}
