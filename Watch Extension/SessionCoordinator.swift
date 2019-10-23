import Common
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
            store?.send(.session(.loggedIn))
        } else if session.receivedApplicationContext["loggedOut"] != nil {
            store?.send(.session(.loggedOut))
        }
    }

    func session(_: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        // TODO: change this into codable or something better
        if applicationContext["loggedIn"] != nil {
            store?.send(.session(.loggedIn))
        } else if applicationContext["loggedOut"] != nil {
            store?.send(.session(.loggedOut))
        }
    }

    func session(_ session: WCSession,
                 didReceiveMessageData messageData: Data,
                 replyHandler: @escaping (Data) -> Void) {
        // This is just used as a succesfull communication reply
        defer { replyHandler(Data()) }

        let decoder = JSONDecoder()
        guard let info = try? decoder.decode(WatchCommunication.self, from: messageData) else { return }

        // TODO: look into if we can get rid of the `.none` case
        guard info.feedingType != .none else { return }

        guard let s = store else { return }

        switch info.action {
        case .start:
            s.send(.feeding(.start(type: info.feedingType, side: info.feedingSide)))
        case .stop:
            s.send(.feeding(.stop(type: info.feedingType)))
        case .pause:
            s.send(.feeding(.pause(type: info.feedingType)))
        case .resume:
            s.send(.feeding(.resume(type: info.feedingType)))
        }
    }
}
