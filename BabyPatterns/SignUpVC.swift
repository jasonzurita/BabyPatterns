//
//  SignUpVC.swift
//  BabyPatterns
//
//  Created by Jason Zurita on 1/13/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit
import FirebaseAuth
import Library
import Framework_BabyPatterns

class SignUpVC: UIViewController, Loggable, Validatable {
    let shouldPrintDebugLog = true

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    private var profileVM: ProfileVM? = ProfileVM()

    @IBOutlet weak var babyNameTextField: ShakeTextField!
    @IBOutlet weak var babyDOBTextField: ShakeTextField!
    @IBOutlet weak var nameTextField: ShakeTextField!
    @IBOutlet weak var emailTextField: ShakeTextField!
    @IBOutlet weak var passwordTextField: ShakeTextField!
    @IBOutlet weak var submitActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var babyInfoContainer: UIView!
    @IBOutlet weak var parentInfoContainer: UIView!

    override func viewDidLoad() {
        configureSignUpContainerView(containerLayer: babyInfoContainer.layer)
        configureSignUpContainerView(containerLayer: parentInfoContainer.layer)
        super.viewDidLoad()
    }

    private func configureSignUpContainerView(containerLayer: CALayer) {
        containerLayer.borderColor = UIColor(red: 0, green: 153 / 255, blue: 255 / 255, alpha: 1).cgColor
        containerLayer.masksToBounds = true
    }

    @IBAction func dismissButtonTapped(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func submitButtonPressed(_: UIButton) {

        guard allTextFieldsValid() else { return }

        guard let email = emailTextField.text, let password = passwordTextField.text else {
            signUpFailed(message: "Please check your email and password and try again.")
            return
        }

        submitActivityIndicator.startAnimating()

        Auth.auth().createUser(withEmail: email, password: password) { user, error in
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

        let babyNameResult = validate(babyNameTextField.text, type: .text(length: 1))
        let babyDOBResult = validate(babyDOBTextField.text, type: .dateOfBirth)
        let nameResult = validate(nameTextField.text, type: .text(length: 1))
        let emailResult = validate(emailTextField.text, type: .email)
        let passwordResult = validate(passwordTextField.text, type: .password)

        if case .failure = babyNameResult { babyNameTextField.shake() }
        if case .failure = babyDOBResult { babyDOBTextField.shake() }
        if case .failure = nameResult { nameTextField.shake() }
        if case .failure = emailResult { emailTextField.shake() }
        if case .failure = passwordResult { passwordTextField.shake() }

        let resultReasons = [babyNameResult, babyDOBResult, nameResult, emailResult, passwordResult].flatMap {
            guard case let .failure(reason) = $0 else { return nil }
            return reason
        }

        return resultReasons.isEmpty
    }

    private func signUpFailed(message: String, error: Error? = nil) {
        submitActivityIndicator.stopAnimating()

        log(error?.localizedDescription ?? message, object: self, type: .error)

        let alert = UIAlertController(title: "Trouble Signing Up", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }

    private func signedUp(user: User) {
        submitActivityIndicator.stopAnimating()
        log("User id: \(user.uid)", object: self, type: .info)

        profileVM?.profile = makeProfile(userID: user.uid)
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
                       email: email,
                       userID: userID,
                       desiredMaxSupply: K.Defaults.DefaultDesiredMaxSupply)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let navigationVC = segue.destination as? UINavigationController,
            let homeVC = navigationVC.topViewController as? HomeVC {
            homeVC.profileVM = profileVM
            profileVM = nil
        }
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
