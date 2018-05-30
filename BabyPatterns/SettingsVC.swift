import Firebase
import Framework_BabyPatterns
import Library
import UIKit

final class SettingsVC: UITableViewController, Loggable {
    let shouldPrintDebugLog = true

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    var profileVM: ProfileVM?
    var configuration: Configuration? {
        didSet {
            configureAdsOffSwitch()
        }
    }
    @IBOutlet var adsOffSwitch: UISwitch! {
        didSet {
            configureAdsOffSwitch()
        }
    }
    @IBOutlet var resetPasswordCell: UITableViewCell!
    @IBOutlet var contactSupportCell: UITableViewCell!
    @IBOutlet var logoutCell: UITableViewCell!

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var babyNameTextField: UITextField!
    @IBOutlet var desiredSupplyTextField: UITextField! {
        didSet {
            let keyboardToolbar = UIToolbar()
            keyboardToolbar.sizeToFit()
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                target: nil,
                                                action: nil)
            let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                                target: self,
                                                action: #selector(numberPadDoneButtonPressed))
            keyboardToolbar.items = [flexibleSpace, doneBarButton]
            desiredSupplyTextField.inputAccessoryView = keyboardToolbar
        }
    }

    @objc func numberPadDoneButtonPressed() {
        _ = textFieldShouldReturn(desiredSupplyTextField)
    }

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
        desiredSupplyTextField.text = "\(p.desiredMaxSupply)"
    }

    private func setupFooter() {
        let footerView = UILabel(frame: CGRect(x: 15, y: 15, width: tableView.frame.width - 15, height: 50))
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: K.DictionaryKeys.VersionNumber) as? String ?? "N/A"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: K.DictionaryKeys.BuildNumber) as? String ?? ""
        footerView.text = "version: \(versionNumber) (\(buildNumber))"
        tableView.tableFooterView = footerView
    }

    private func configureAdsOffSwitch() {
        guard let c = configuration, adsOffSwitch != nil else { return }

        switch c.adsState {
        case .show, .initialInstall:
            adsOffSwitch.setOn(false, animated: true)
        case .hide:
            adsOffSwitch.setOn(true, animated: true)
        }
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
        guard let c = configuration else { return }
        switch c.adsState {
        case .hide:
            configuration?.adsState = .show
        case .show:
            configuration?.adsState = .hide
        case .initialInstall:
            adsOffSwitch.isOn = false
            // TODO: show ad removal screen here
        }
    }

    @IBAction func desiredSupplyTextFieldDidFinishEditing(_ sender: UITextField) {
        // TODO: validate desiredSupply
        guard let text = sender.text, let desiredSupply = Double(text) else {
            fieldNotValid(message: "Chceck number and try again.")
            return
        }

        profileVM?.profile?.desiredMaxSupply = desiredSupply
        profileVM?.profileUpdated()
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
