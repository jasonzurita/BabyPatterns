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
            Auth.auth().createUser(withEmail: email, password: password) { [unowned self] user, error in
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
                    self.profileVM?.profile = Profile(babyName: babyName,
                                                      parentName: parentName,
                                                      babyDOB: Date(),
                                                      email: email,
                                                      userID: u.uid,
                                                      desiredMaxSupply: K.Defaults.DefaultDesiredMaxSupply)
                    self.profileVM?.sendToServer()
                    self.userLoggedIn(user: u)
                })
            }
        }

        vc.onLoginRequested = {
            // TODO: implement this
        }

        present(vc, animated: false, completion: nil)
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
            let homeVC = navigationVC.topViewController as? HomeVC {
            homeVC.feedingsVM = feedingsVM
            homeVC.profileVM = profileVM
            homeVC.configuration = Configuration(defaults: UserDefaults.standard)
            feedingsVM = nil
            profileVM = nil
            didRequestProfile = false
            didRequestFeedings = false
        }
    }
}
