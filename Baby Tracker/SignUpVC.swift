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

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var babyNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func submitButtonPressed(_ sender: RoundedCornerButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedUp(user: user)
            //            self.setDisplayName(user!)
        }
    }
    
    private func signedUp(user:FIRUser?) {
        if let user = user {
            print("User id: \(user.uid)")
        }
        performSegue(withIdentifier: Constants.Segues.SignedUpSegue, sender: nil)
    }

}
