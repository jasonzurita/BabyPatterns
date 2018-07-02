import FirebaseAuth
import Framework_BabyPatterns
import Library
import UIKit

final class SignInVC: UIViewController, Loggable {
    let shouldPrintDebugLog = true

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signInContainerView: UIView!

    @IBOutlet var signInActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSignInContainerView(containerLayer: signInContainerView.layer)
    }

    private func configureSignInContainerView(containerLayer: CALayer) {
        containerLayer.borderColor = UIColor(red: 0, green: 153 / 255, blue: 255 / 255, alpha: 1).cgColor
        containerLayer.masksToBounds = true
    }

    @IBAction func signIn(_: UIButton) {
        signInActivityIndicator.startAnimating()
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            signInFailed()
            return
        }

        Auth.auth().signIn(withEmail: email, password: password, completion: { user, error in
            if let error = error {
                self.signInFailed(error: error)
            } else {
                self.signedIn(user: user)
            }
        })
    }

    private func signInFailed(error: Error? = nil) {
        signInActivityIndicator.stopAnimating()

        log(error?.localizedDescription ?? "Trouble signing in...", object: self, type: .error)

        let alert = UIAlertController(title: "Trouble Signing In",
                                      message: "Please check your email and password and try again.",
                                      preferredStyle: .alert)

        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }

    private func signedIn(user: User?) {
        signInActivityIndicator.stopAnimating()

        if let user = user {
            log("User id: \(user.uid)", object: self, type: .info)
        }
        performSegue(withIdentifier: K.Segues.SignedIn, sender: nil)
    }

    @IBAction func forgotPassword(_: UIButton) {
        let prompt = UIAlertController(title: "Reset Password?",
                                       message: "Enter your email then check that email for further instrucitons:",
                                       preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let userInput = prompt.textFields?[0].text, !userInput.isEmpty else { return }

            Auth.auth().sendPasswordReset(withEmail: userInput, completion: { [weak self] error in
                if let error = error, let s = self {
                    // TODO: revist this because we want to print this error regardless if self is available
                    s.log(error.localizedDescription, object: s, type: .error)
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
}

extension SignInVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
