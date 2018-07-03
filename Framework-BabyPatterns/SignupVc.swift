import UIKit
import Library

public final class SignupVc: UIViewController, Loggable, Validatable {
    public let shouldPrintDebugLog = true

    public typealias SignupResultHandler =
        (
        _ email: String,
        _ password: String,
        _ parentName: String,
        _ babyName: String
        ) -> Void

    public var onSignup: SignupResultHandler?
    public var onLoginRequested: (() -> Void)?

    @IBOutlet var containerCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var containerView: UIView!
    @IBOutlet var submitButton: UIButton!
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
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        submitActivityIndicator.stopAnimating()
    }

    @IBAction func submitButtonPressed(_: UIButton) {
        guard areAllTextFieldsValid() else { return }

        submitButton.isEnabled = false
        submitActivityIndicator.startAnimating()
        defer { containerView.endEditing(false); resetContainerHeight() }

        guard let email = emailTextField.text, let password = passwordTextField.text else {
            signUpFailed(message: "Please check your email and password and try again.")
            return
        }
        let parentName = nameTextField.text ?? "None"
        let babyName = babyNameTextField.text ?? "None"
        onSignup?(email, password, parentName, babyName)
    }

    private func resetContainerHeight() {
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.25) {
            self.containerCenterYConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
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

    public func signUpFailed(message: String = "", error: Error? = nil) {
        submitButton.isEnabled = true
        submitActivityIndicator.stopAnimating()

        // TODO: consider using the error for the user message
        log(error?.localizedDescription ?? message, object: self, type: .error)

        let alert = UIAlertController(title: "Trouble Signing Up", message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
}

extension SignupVc: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        resetContainerHeight()
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
