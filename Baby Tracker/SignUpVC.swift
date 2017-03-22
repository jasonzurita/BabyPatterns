//
//  SignUpVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/13/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpVC: UIViewController {
    private let shouldPrintDebugString = true
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private var profileVM:ProfileVM? = ProfileVM()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var babyNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func submitButtonPressed(_ sender: UIButton) {
        submitActivityIndicator.startAnimating()
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            signUpFailed(message:"Please check your email and password and try again.")
            return
        }
        
        do {
            try validateSignUpCredentials()
        } catch let error as SignUpValidationError {
            signUpFailed(message: error.rawValue)
            return
        } catch {
            signUpFailed(message: "Unkown error.")
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.signUpFailed(message: "", error: error)
                return
            }
            self.signedUp(user: user)
        }
    }
    
    private func validateSignUpCredentials() throws {
        
        guard let name = nameTextField.text, !name.isEmpty else { throw SignUpValidationError.noNameEntered }
        
        guard let babyName = babyNameTextField.text, !babyName.isEmpty else { throw SignUpValidationError.noBabyNameEntered }
    }
    
    private func signUpFailed(message:String, error:Error? = nil) {
        submitActivityIndicator.stopAnimating()
        
        Logger.log(message: error?.localizedDescription ?? message, object: self, type: .error, shouldPrintDebugLog: self.shouldPrintDebugString)
        
        let alert = UIAlertController(title: "Trouble Signing Up", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func signedUp(user:FIRUser?) {
        submitActivityIndicator.stopAnimating()
        if let user = user {
            Logger.log(message: "User id: \(user.uid)", object: self, type: .info, shouldPrintDebugLog: shouldPrintDebugString)
        }

        profileVM?.profile = makeProfile()
        profileVM?.sendToServer()
        
        performSegue(withIdentifier: K.Segues.SignedUpSegue, sender: nil)
    }
    
    private func makeProfile() -> Profile {
        let parentName = nameTextField.text ?? "None"
        let babyName = babyNameTextField.text ?? "None"
        let email = emailTextField.text ?? "None"
        return Profile(babyName: babyName, parentName: parentName, babyDOB: Date(), email:email)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? UINavigationController, let homeVC = navigationVC.topViewController as? HomeVC {
            homeVC.profileVM = profileVM
            profileVM = nil
        }
    }
}
