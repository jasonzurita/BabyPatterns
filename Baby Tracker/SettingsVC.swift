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
    
    fileprivate let settingsList = ["Name", "Baby Name", "Baby DOB", "Email", "Reset Password", "Get rid of ads", "App Suggestions" ,"App Version", "Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO
    }
}

extension SettingsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = settingsList[indexPath.row]
        return cell
    }
}
