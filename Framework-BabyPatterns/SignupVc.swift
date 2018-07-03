import UIKit
import Library

public final class SignupVc: UIViewController, Loggable, Validatable {
    public let shouldPrintDebugLog = true

    @IBOutlet var containerCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var containerView: UIView!

    @IBOutlet var babyNameTextField: ShakeTextField!
    @IBOutlet var babyDOBTextField: ShakeTextField!
    @IBOutlet var nameTextField: ShakeTextField!
    @IBOutlet var emailTextField: ShakeTextField!
    @IBOutlet var passwordTextField: ShakeTextField!
    @IBOutlet var submitActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var babyInfoContainer: UIView! {
        didSet {
            // TODO style
        }
    }
    @IBOutlet var parentInfoContainer: UIView!

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    public init() {
        super.init(nibName: "\(type(of: self))", bundle: Bundle.framework)
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    public override func viewDidLoad() {
//        configureSignUpContainerView(containerLayer: babyInfoContainer.layer)
//        configureSignUpContainerView(containerLayer: parentInfoContainer.layer)
        super.viewDidLoad()
    }

//    private func configureSignUpContainerView(containerLayer: CALayer) {
//        containerLayer.borderColor = UIColor(red: 0, green: 153 / 255, blue: 255 / 255, alpha: 1).cgColor
//        containerLayer.masksToBounds = true
//    }
    @IBAction func submitButtonPressed(_: UIButton) {
        guard areAllTextFieldsValid() else { return }

        guard let email = emailTextField.text, let password = passwordTextField.text else {
            signUpFailed(message: "Please check your email and password and try again.")
            return
        }

        submitActivityIndicator.startAnimating()

//        Auth.auth().createUser(withEmail: email, password: password) { user, error in
//            guard error == nil else {
//                self.signUpFailed(message: "", error: error)
//                return
//            }
//            guard let u = user else {
//                self.signUpFailed(message: "Failed to create account. Please try again.")
//                return
//            }
//            self.signedUp(user: u)
//        }
    }

    private func areAllTextFieldsValid() -> Bool {
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

        let reasons = [babyNameResult, babyDOBResult, nameResult, emailResult, passwordResult]
        let resultReasons = reasons.compactMap { (result: ValidationResult) -> String? in
            guard case let .failure(reason) = result else { return nil }
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

//    private func signedUp(user: User) {
//        submitActivityIndicator.stopAnimating()
//        log("User id: \(user.uid)", object: self, type: .info)
//
//        profileVM?.profile = makeProfile(userID: user.uid)
//        profileVM?.sendToServer()
//    }

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
}

extension SignupVc: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.25) {
            self.containerCenterYConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        return true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let delta = (view.frame.height - containerView.frame.height - view.safeAreaInsets.top) * 0.5
        log("Container view Y offset: \(delta)", object: self, type: .info)

        view.setNeedsLayout()
        UIView.animate(withDuration: 0.25) {
            self.containerCenterYConstraint.constant = -delta
            self.view.layoutIfNeeded()
        }
    }
}
