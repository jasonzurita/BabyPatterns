//
//  SettingsVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/7/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit
import Firebase

class SettingsVC: UITableViewController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //cells
    @IBOutlet weak var resetPasswordCell: UITableViewCell!
    @IBOutlet weak var contactSupportCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    //text fileds
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var babyNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = "example@example.com"
        let footerView = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        footerView.text = "App version: awesome.awesome"
        tableView.tableFooterView = footerView
    }
    
    @IBAction func emailTextFieldDidFinishEditing(_ sender: UITextField) {
    }
    @IBAction func nameTextFieldDidFinishEditing(_ sender: UITextField) {
    }
    
    @IBAction func babyNameTextFieldDidFinishEditing(_ sender: UITextField) {
    }
    
    @IBAction func turnOffAdsSwitchPressed(_ sender: UISwitch) {
    }
}

extension SettingsVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        if selectedCell == resetPasswordCell {
            resetPassword()
        } else if selectedCell == contactSupportCell {
            contactSupport()
        } else if selectedCell == logoutCell {
            logout()
        } else {
            print("Non static cell selected...")
        }
    }
    
    private func resetPassword() {
        
    }
    
    private func contactSupport() {
        
    }
    
    private func logout() {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            dismiss(animated: true, completion: nil)
        } catch let signOutError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }

}

