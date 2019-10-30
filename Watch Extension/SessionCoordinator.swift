import Common
import Foundation
import WatchConnectivity

final class SessionCoordinator: NSObject {
    static let shared = SessionCoordinator()
    weak var store: Store<AppState, AppAction>? {
        didSet {
            store?.send(.context(.requestFullContext))
        }
    }

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
        if let data = session.receivedApplicationContext["feedings"] as? Data,
            let feedings = try? decoder.decode([Feeding].self, from: data) {
            store?.send(.feeding(.update(feedings: feedings)))
        }

        if session.receivedApplicationContext["loggedIn"] != nil {
            store?.send(.session(.loggedIn))
        } else if session.receivedApplicationContext["loggedOut"] != nil {
            store?.send(.session(.loggedOut))
        }
    }

    func session(_: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        let decoder = JSONDecoder()
        if let data = applicationContext["feedings"] as? Data,
            let feedings = try? decoder.decode([Feeding].self, from: data) {
            store?.send(.feeding(.update(feedings: feedings)))
        }

        // TODO: change this into codable or something better
        if applicationContext["loggedIn"] != nil {
            store?.send(.session(.loggedIn))
        } else if applicationContext["loggedOut"] != nil {
            store?.send(.session(.loggedOut))
        }
    }

    func session(_: WCSession,
                 didReceiveMessageData messageData: Data,
                 replyHandler: @escaping (Data) -> Void) {
        // This is just used as a succesfull communication reply
        defer { replyHandler(Data()) }

        let decoder = JSONDecoder()
        guard let info = try? decoder.decode(WatchFeedingCommunication.self, from: messageData) else { return }

        // TODO: look into if we can get rid of the `.none` case
        guard info.feedingType != .none else { return }

        guard let s = store else { return }

        switch info.action {
        case .start:
            s.send(.newFeeding(.start(type: info.feedingType, side: info.feedingSide)))
        case .stop:
            s.send(.newFeeding(.stop(type: info.feedingType)))
        case .pause:
            s.send(.newFeeding(.pause(type: info.feedingType)))
        case .resume:
            s.send(.newFeeding(.resume(type: info.feedingType)))
        }
    }
}
