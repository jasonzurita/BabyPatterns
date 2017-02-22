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

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private var profile:Profile?
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var babyNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func submitButtonPressed(_ sender: UIButton) {
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
        
        sendProfileToServer()
        
        performSegue(withIdentifier: K.Segues.SignedUpSegue, sender: nil)
    }
    
    private func sendProfileToServer() {
        let firebaseFacade = FirebaseFacade()
        profile = makeProfile()
        firebaseFacade.uploadJSON(self.profile!.json(), requestType: .profile)
    }
    
    private func makeProfile() -> Profile {
        let parentName = nameTextField.text ?? "None"
        let babyName = babyNameTextField.text ?? "None"
        let email = emailTextField.text ?? "None"
        return Profile(babyName: babyName, parentName: parentName, profilePicture: UIImage(), babyDOB: Date(), email:email)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationVC = segue.destination as? UINavigationController, let homeVC = navigationVC.topViewController as? HomeVC, let p = profile {
            homeVC.profile = p
            profile = nil
        }
    }
}
