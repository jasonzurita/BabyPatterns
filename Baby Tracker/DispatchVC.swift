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

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var feedings:FeedingFacadeVM?
    
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
        
        feedings = FeedingFacadeVM()
        
        //TODO: loading failed
//        self.performSegue(withIdentifier: Constants.Segues.LoggedInSegue, sender: nil)

        feedings!.loadData(completionHandler: { _ in
            self.performSegue(withIdentifier: Constants.Segues.LoggedInSegue, sender: nil)

        })
    }
    
    private func userLoggedOut() {
        performSegue(withIdentifier: Constants.Segues.LoggedOutSegue, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let homeVC = segue.destination as? HomeVC, let f = feedings {
            homeVC.feedings = f
            feedings = nil
        }
    }

}
