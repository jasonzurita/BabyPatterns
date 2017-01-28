//
//  SettingsVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/7/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit
import Firebase

class SettingsVC: UIViewController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signOut(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        
        do {
            try firebaseAuth?.signOut()
            dismiss(animated: true, completion: nil)
        } catch let signOutError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}
