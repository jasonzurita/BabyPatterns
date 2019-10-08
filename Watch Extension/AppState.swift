import Common
import Swift
import WatchConnectivity

// TODO: this should be combined (or sorted out) with the iOS app's Feeding struct
struct Feeding: Identifiable {
    let id = UUID()
    let start: Date
    let type: FeedingType
    let side: FeedingSide
}

struct AppState {
    enum SessionState {
        case loggedIn
        case loggedOut
    }

    var activeFeedings: [Feeding] = []
    var timerPulseCount: Int = 0
    var session: SessionState = .loggedOut
}

enum AppAction {
    case loggedIn
    case loggedOut
    case timerPulse
    case start(type: FeedingType, side: FeedingSide)
    case stop(Feeding)
    case pause(Feeding)
}

// TODO: see what can be DRY-ed up here
func appReducer(value: inout AppState, action: AppAction) {
    switch action {
    // TODO: can logged out and logged in be combined?
    case .loggedIn:
        value.session = .loggedIn
    case .loggedOut:
        value.session = .loggedOut
    case .timerPulse:
        value.timerPulseCount += 1
    case let .start(type, side):
        let info = WatchCommunication(type: type,
                                      side: side,
                                      action: .start)
        let jsonEncoder = JSONEncoder()
        guard let d = try? jsonEncoder.encode(info) else {
            // TODO: what do we do here?
            return
        }

        WCSession.default.sendMessageData(d, replyHandler: nil) { e in
            print("Error sending the message: \(e.localizedDescription)")
        }
        // TODO: this should be placed in the success blok from the communication
        // TODO: need to gracefully handle a failure here
        let feeding = Feeding(start: Date(), type: type, side: side)
        value.activeFeedings.append(feeding)
    case let .stop(feeding):
        let info = WatchCommunication(type: feeding.type,
                                      side: feeding.side,
                                      action: .stop)
        let jsonEncoder = JSONEncoder()
        guard let d = try? jsonEncoder.encode(info) else {
            // TODO: what do we do here?
            return
        }
        WCSession.default.sendMessageData(d, replyHandler: nil) { e in
            print("Error sending the message: \(e.localizedDescription)")
        }
        value.activeFeedings.removeAll { $0.id == feeding.id }
    case let .pause(feeding):
        let info = WatchCommunication(type: feeding.type,
                                      side: feeding.side,
                                      action: .pause)
        let jsonEncoder = JSONEncoder()
        guard let d = try? jsonEncoder.encode(info) else {
            // TODO: what do we do here?
            return
        }
        WCSession.default.sendMessageData(d, replyHandler: nil) { e in
            print("Error sending the message: \(e.localizedDescription)")
        }
    }
}
