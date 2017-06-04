//
//  SignUpVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/13/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpVC: UIViewController, Loggable {
    let shouldPrintDebugLog = true

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    private var profileVM: ProfileVM? = ProfileVM()

    @IBOutlet weak var babyNameTextField: ValidationTextField!
    @IBOutlet weak var babyDOBTextField: ValidationTextField!
    @IBOutlet weak var nameTextField: ValidationTextField!
    @IBOutlet weak var emailTextField: ValidationTextField!
    @IBOutlet weak var passwordTextField: ValidationTextField!
    @IBOutlet weak var submitActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var babyInfoContainer: UIView!
    @IBOutlet weak var parentInfoContainer: UIView!

    override func viewDidLoad() {
        configureSignUpContainerView(containerLayer: babyInfoContainer.layer)
        configureSignUpContainerView(containerLayer: parentInfoContainer.layer)
        super.viewDidLoad()
    }

    private func configureSignUpContainerView(containerLayer: CALayer) {
        containerLayer.borderColor = UIColor(colorLiteralRed: 0, green: 153/255, blue: 255/255, alpha: 1).cgColor
        containerLayer.masksToBounds = true
    }

    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func submitButtonPressed(_ sender: UIButton) {

        guard allTextFieldsValid() else { return }

        guard let email = emailTextField.text, let password = passwordTextField.text else {
            signUpFailed(message:"Please check your email and password and try again.")
            return
        }

        submitActivityIndicator.startAnimating()

        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            guard error == nil else {
                self.signUpFailed(message: "", error: error)
                return
            }
            guard let u = user else {
                self.signUpFailed(message: "Failed to create account. Please try again.")
                return
            }
            self.signedUp(user: u)
        }
    }

    private func allTextFieldsValid() -> Bool {
        return babyNameTextField.isValid() &&
            babyDOBTextField.isValid() &&
            nameTextField.isValid() &&
            emailTextField.isValid() &&
            passwordTextField.isValid()
    }

    private func signUpFailed(message: String, error: Error? = nil) {
        submitActivityIndicator.stopAnimating()

        log(error?.localizedDescription ?? message, object: self, type: .error)

        let alert = UIAlertController(title: "Trouble Signing Up", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }

    private func signedUp(user: FIRUser) {
        submitActivityIndicator.stopAnimating()
        log("User id: \(user.uid)", object: self, type: .info)

        profileVM?.profile = makeProfile(userID:user.uid)
        profileVM?.sendToServer()

        performSegue(withIdentifier: K.Segues.SignedUp, sender: nil)
    }

    private func makeProfile(userID: String) -> Profile {
        let parentName = nameTextField.text ?? "None"
        let babyName = babyNameTextField.text ?? "None"
        let email = emailTextField.text ?? "None"
        return Profile(babyName: babyName,
                       parentName: parentName,
                       babyDOB: Date(),
                       email:email,
                       userID:userID,
                       desiredMaxSupply:K.Defaults.DefaultDesiredMaxSupply)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? UINavigationController,
           let homeVC = navigationVC.topViewController as? HomeVC {
            homeVC.profileVM = profileVM
            profileVM = nil
        }
    }
}
