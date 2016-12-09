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
        containerLayer.borderColor = UIColor.gray.cgColor
        containerLayer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user: user)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signIn(_ sender: Any) {
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
}
