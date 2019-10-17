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
    var didCommunicationFail = false
    /*
     TODO: think about this some more.
     I am not too sure how much I like this.
     It is a bit of a weird side effect, but for now
     it gets the job done.
     */
    var showSavedFyiDialog = false
}

enum AppAction {
    case loggedIn
    case loggedOut
    case timerPulse
    case clearFailedCommunication
    case hideSavedFyiDialog
    case start(type: FeedingType, side: FeedingSide)
    case stop(Feeding)
    case pause(Feeding)
}

// TODO: see what can be DRY-ed up here
// swiftlint:disable function_body_length
func appReducer(value: inout AppState, action: AppAction) {
    switch action {
    // TODO: can logged out and logged in be combined?
    case .loggedIn:
        value.session = .loggedIn
    case .loggedOut:
        value.session = .loggedOut
    case .timerPulse:
        value.timerPulseCount += 1
    case .clearFailedCommunication:
        value.didCommunicationFail = false
    case .hideSavedFyiDialog:
        value.showSavedFyiDialog = false
    case let .start(type, side):
        let info = WatchCommunication(type: type,
                                      side: side,
                                      action: .start)

        let jsonEncoder = JSONEncoder()
        guard let d = try? jsonEncoder.encode(info), WCSession.default.isReachable else {
            value.didCommunicationFail = true
            return
        }

        WCSession.default.sendMessageData(d, replyHandler: nil) { error in
            // TODO: should gracefully handle a failure here
            print("Error sending the message: \(error.localizedDescription)")
            assertionFailure()
        }
        // TODO: this should really be placed in the success block
        // from the communication above, but mutating the value in an
        // escaping block needs to be worked out. Can we send from the block?
        let feeding = Feeding(start: Date(), type: type, side: side)
        value.activeFeedings.append(feeding)
    case let .stop(feeding):
        let info = WatchCommunication(type: feeding.type,
                                      side: feeding.side,
                                      action: .stop)
        let jsonEncoder = JSONEncoder()
        guard let d = try? jsonEncoder.encode(info), WCSession.default.isReachable else {
            value.didCommunicationFail = true
            return
        }

        WCSession.default.sendMessageData(d, replyHandler: nil) { error in
            // TODO: should gracefully handle a failure here
            print("Error sending the message: \(error.localizedDescription)")
            assertionFailure()
        }
        // TODO: this should really be placed in the success block
        // from the communication above, but mutating the value in an
        // escaping block needs to be worked out. Can we send from the block?
        value.activeFeedings.removeAll { $0.id == feeding.id }
        value.showSavedFyiDialog = true
    case let .pause(feeding):
        let info = WatchCommunication(type: feeding.type,
                                      side: feeding.side,
                                      action: .pause)
        let jsonEncoder = JSONEncoder()
        guard let d = try? jsonEncoder.encode(info), WCSession.default.isReachable else {
            value.didCommunicationFail = true
            return
        }

        WCSession.default.sendMessageData(d, replyHandler: nil) { error in
            // TODO: should gracefully handle a failure here
            print("Error sending the message: \(error.localizedDescription)")
            assertionFailure()
        }
    }
}
// swiftlint:enable function_body_length
