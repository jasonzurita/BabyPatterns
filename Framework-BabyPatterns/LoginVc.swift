import UIKit
import Library

public final class LoginVc: UIViewController, Loggable {
    public let shouldPrintDebugLog = true

    public var onLogIn: ((_ email: String, _ password: String) -> Void)?
    public var onForgotPassword: ((_ email: String) -> Void)?

    @IBOutlet var titleLabel: UILabel! {
        didSet {
            styleLabelTitle(titleLabel)
        }
    }
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var allTextFields: [UITextField]!
    @IBOutlet var logInButton: UIButton! {
        didSet {
            styleButtonRounded(.bpMediumBlue)(logInButton)
        }
    }
    @IBOutlet var forgotButton: UIButton! {
        didSet {
            styleButtonFont(.notoSansRegular(ofSize: 16))(forgotButton)
        }
    }
    @IBOutlet var logInActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var loginContainerView: UIView! {
        didSet {
            styleViewBorder(loginContainerView)
        }
    }
    @IBOutlet var containerView: UIView!
    @IBOutlet var containerCenterYConstraint: NSLayoutConstraint!

    public init() {
        super.init(nibName: "\(type(of: self))", bundle: Bundle.framework)
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        allTextFields.forEach(styleTextFieldBase)
    }

    @IBAction func logIn(_ sender: UIButton) {
        logInActivityIndicator.startAnimating()
//        defer { containerView.endEditing(false); resetContainerHeight() }
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            logInFailed()
            return
        }
        onLogIn?(email, password)
    }

    @IBAction func forgotPassword(_ sender: UIButton) {
        let prompt = UIAlertController(title: "Reset Password?",
                                       message: "Enter your email then check that email for further instrucitons:",
                                       preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let email = prompt.textFields?[0].text, !email.isEmpty else { return }
            self.onForgotPassword?(email)
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        prompt.addAction(cancelAction)
        present(prompt, animated: true, completion: nil)
    }

    public func logInFailed(error: Error? = nil) {
        logInActivityIndicator.stopAnimating()

        log(error?.localizedDescription ?? "Trouble signing in...", object: self, type: .error)

        let alert = UIAlertController(title: "Trouble Signing In",
                                      message: "Please check your email and password and try again.",
                                      preferredStyle: .alert)

        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true, completion: nil)
    }
}
