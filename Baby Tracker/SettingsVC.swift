//
//  SettingsVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/7/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit
import Firebase

class SettingsVC: UITableViewController, Loggable {
    let shouldPrintDebugLog = true

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    var profileVM: ProfileVM?

    // cells
    @IBOutlet weak var resetPasswordCell: UITableViewCell!
    @IBOutlet weak var contactSupportCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!

    //text fileds
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var babyNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupProfileUI()
        setupFooter()
    }

    private func setupProfileUI() {
        guard let p = profileVM?.profile else { return }
        emailTextField.text = p.email
        nameTextField.text = p.parentName
        babyNameTextField.text = p.babyName
    }

    private func setupFooter() {
        let footerView = UILabel(frame: CGRect(x: 15, y: 15, width: tableView.frame.width - 15, height: 50))
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: K.DictionaryKeys.VersionNumber) as? String ?? "N/A"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: K.DictionaryKeys.BuildNumber) as? String ?? ""
        footerView.text = "version: \(versionNumber) (\(buildNumber))"
        tableView.tableFooterView = footerView
    }

    @IBAction func emailTextFieldDidFinishEditing(_ sender: UITextField) {
        guard let email = sender.text, email.validateEmail() else {
            fieldNotValid(message: "Invalid email. Try again.")
            return
        }

        profileVM?.profile?.email = email
        profileVM?.profileUpdated()
    }

    @IBAction func nameTextFieldDidFinishEditing(_ sender: UITextField) {
        guard let name = sender.text else { return }
        profileVM?.profile?.parentName = name
        profileVM?.profileUpdated()
    }

    @IBAction func babyNameTextFieldDidFinishEditing(_ sender: UITextField) {
        guard let name = sender.text else { return }
        profileVM?.profile?.babyName = name
        profileVM?.profileUpdated()
    }

    @IBAction func turnOffAdsSwitchPressed(_: UISwitch) {
    }

    private func fieldNotValid(message _: String) {
        // present popup here
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
            log("Non static cell selected...", object: self, type: .warning)
        }
    }

    private func resetPassword() {
    }

    private func contactSupport() {
    }

    private func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            dismiss(animated: true, completion: nil)
        } catch let signOutError {
            log("Error signing out: \(signOutError.localizedDescription)", object: self, type: .error)
        }
    }
}

extension SettingsVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
