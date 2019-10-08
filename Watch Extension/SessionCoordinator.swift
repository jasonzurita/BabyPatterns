import Foundation
import WatchConnectivity

final class SessionCoordinator: NSObject {
    static let shared = SessionCoordinator()
    weak var store: Store<AppState, AppAction>?

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
}

extension SessionCoordinator: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith _: WCSessionActivationState, error: Error?) {
        print("Completed activation: \(error?.localizedDescription ?? "no error")")
        if session.receivedApplicationContext["loggedIn"] != nil {
            DispatchQueue.main.async {
                self.store?.send(.loggedIn)
            }
        } else if session.receivedApplicationContext["loggedOut"] != nil {
            DispatchQueue.main.async {
                self.store?.send(.loggedOut)
            }
        }
    }

    func session(_: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        // TODO: change this into codable or something better
        if applicationContext["loggedIn"] != nil {
            DispatchQueue.main.async {
                self.store?.send(.loggedIn)
            }
        } else if applicationContext["loggedOut"] != nil {
            DispatchQueue.main.async {
                self.store?.send(.loggedOut)
            }
        }
    }
}
