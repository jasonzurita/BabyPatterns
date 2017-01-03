//
//  SignInVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/16/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSignInContainerView(containerLayer: signInContainerView.layer)
    }
    
    private func configureSignInContainerView(containerLayer:CALayer) {
        containerLayer.borderColor = UIColor(colorLiteralRed: 0, green: 153/255, blue: 255/255, alpha: 1).cgColor
        containerLayer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user: user)
        }
    }
    
    @IBAction func signIn(_ sender: RoundedCornerButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.signedIn(user: user)
            }
        })
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        
        let prompt = UIAlertController(title: "Reset Password?", message: "Enter your email then check that email for further instrucitons:", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            guard let userInput = prompt.textFields?[0].text, !userInput.isEmpty else { return }
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput, completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        prompt.addAction(cancelAction)
        present(prompt, animated: true, completion: nil)
    }
    
    
    @IBAction func signUp(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(user: user)
            //            self.setDisplayName(user!)
        }
    }
    
    
    private func signedIn(user:FIRUser?) {
        performSegue(withIdentifier: Constants.Segues.SignInSegue, sender: nil)
    }
    
    @IBAction func tryDemo(_ sender: RoundedCornerButton) {
        //load demo account
    }
    
}
