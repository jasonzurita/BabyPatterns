import Firebase
import Framework_BabyPatterns
import Library
import UIKit

class DispatchVC: UIViewController, Loggable {
    let shouldPrintDebugLog = true

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    private var feedingsVM: FeedingsVM?
    private var profileVM: ProfileVM?

    private var _profileImage: UIImage?

    // TODO: this should be changed to be a bitwise operator
    private var didRequestFeedings = false
    private var didRequestProfile = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
        // TODO: fix the double configuring the db when creating an account
        if let user = Auth.auth().currentUser {
            didRequestProfile = false
            didRequestFeedings = false
            userLoggedIn(user: user)
        } else {
            presentSignup()
        }
    }

    private func presentSignup() {
        let vc = SignupVc()

        vc.onSignup = { (email, password, parentName, babyName) -> Void in
            Auth.auth().createUser(withEmail: email, password: password) { [unowned self, unowned vc] user, error in
                guard error == nil else {
                    vc.signUpFailed(error: error)
                    return
                }
                guard let u = user else {
                    vc.signUpFailed(message: "Failed to create account. Please try again.")
                    return
                }
                vc.dismiss(animated: false, completion: {
                    self.log("User id: \(u.uid)", object: self, type: .info)
                    let maxSupply = SupplyAmount(value: K.Defaults.DefaultDesiredMaxSupply)
                    self.profileVM?.profile = Profile(babyName: babyName,
                                                      parentName: parentName,
                                                      babyDOB: Date(),
                                                      email: email,
                                                      userID: u.uid,
                                                      desiredMaxSupply: maxSupply)
                    self.profileVM?.sendToServer()
                    if let image = self._profileImage {
                        self.profileVM?.updateProfilePhoto(image: image)
                    }
                    self.userLoggedIn(user: u)
                })
            }
        }

        vc.onLogInRequested = { [unowned self, unowned vc] in
            self.logIn(presentingOn: vc)
        }

        vc.onImageChosen = { [unowned self] image in
            self._profileImage = image
        }

        present(vc, animated: false, completion: nil)
    }

    private func logIn(presentingOn rootVc: UIViewController) {
        let vc = LoginVc()

        vc.onLogIn = { [unowned self, unowned vc, unowned rootVc] email, password in
            Auth.auth().signIn(withEmail: email, password: password, completion: { user, error in
                if let error = error {
                    vc.logInFailed(error: error)
                } else {
                    // FIXME: this is real crappy an needs to be fixed
                    self.dismiss(animated: false, completion: {
                        rootVc.dismiss(animated: false, completion: {
                            self.userLoggedIn(user: user)
                        })
                    })
                }
            })
        }

        vc.onForgotPassword = { email in
            Auth.auth().sendPasswordReset(withEmail: email, completion: { [weak self] error in
                if let error = error, let s = self {
                    s.log(error.localizedDescription, object: s, type: .error)
                    // TODO: report error to user
                }
            })
        }

        rootVc.present(vc, animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activityIndicator.stopAnimating()
    }

    private func userLoggedIn(user: User?) {
        if let user = user {
            log("User id: \(user.uid)", object: self, type: .info)
        }

        loadProfile()
        loadFeedings()
    }

    private func loadProfile() {
        let p = ProfileVM()
        profileVM = p
        p.loadProfile(completionHandler: {
            self.didRequestProfile = true
            self.userLoggedIn()
        })
    }

    private func loadFeedings() {
        let f = FeedingsVM()
        feedingsVM = f
        f.loadFeedings(completionHandler: {
            self.didRequestFeedings = true
            self.userLoggedIn()
        })
    }

    private func userLoggedIn() {
        if didRequestFeedings && didRequestProfile {
            performSegue(withIdentifier: K.Segues.LoggedIn, sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if let navigationVC = segue.destination as? UINavigationController,
            let vc = navigationVC.topViewController as? FeedingVC {
            vc.feedingsVM = feedingsVM
            vc.profileVM = profileVM
            vc.configuration = Configuration(defaults: UserDefaults.standard)
            feedingsVM = nil
            profileVM = nil
            didRequestProfile = false
            didRequestFeedings = false
        }
    }
}
