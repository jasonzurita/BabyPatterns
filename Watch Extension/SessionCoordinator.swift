import Common
import Cycle
import Foundation
import WatchConnectivity

enum SessionCoordinatorAction {
    case session(SessionAction)
    case context(ContextAction)
    case feeding(FeedingAction)
}

final class SessionCoordinator: NSObject {
    static let shared = SessionCoordinator()
    var store: Store<Void, SessionCoordinatorAction>?

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
        let decoder = JSONDecoder()

        DispatchQueue.main.async {
            if let data = session.receivedApplicationContext["feedings"] as? Data,
                let feedings = try? decoder.decode([Feeding].self, from: data) {
                self.store?.send(.feeding(.update(feedings: feedings)))
            }

            if session.receivedApplicationContext["loggedIn"] != nil {
                self.store?.send(.session(.loggedIn))
            } else if session.receivedApplicationContext["loggedOut"] != nil {
                self.store?.send(.session(.loggedOut))
            }
        }
    }

    func session(_: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        let decoder = JSONDecoder()
        DispatchQueue.main.async {
            if let data = applicationContext["feedings"] as? Data,
                let feedings = try? decoder.decode([Feeding].self, from: data) {
                self.store?.send(.feeding(.update(feedings: feedings)))
            }

            // TODO: change this into codable or something better
            if applicationContext["loggedIn"] != nil {
                self.store?.send(.session(.loggedIn))
            } else if applicationContext["loggedOut"] != nil {
                self.store?.send(.session(.loggedOut))
            }
        }
    }
}
