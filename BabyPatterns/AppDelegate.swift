import Firebase
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private func application(_: UIApplication,
                             didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIFont.registerFonts
        // TODO: move this into a separate initialization file
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9077495891432075~4439532342")
        return true
    }

    func applicationWillResignActive(_: UIApplication) {
    }

    func applicationDidEnterBackground(_: UIApplication) {
    }

    func applicationWillEnterForeground(_: UIApplication) {
    }

    func applicationDidBecomeActive(_: UIApplication) {
    }

    func applicationWillTerminate(_: UIApplication) {
    }
}
