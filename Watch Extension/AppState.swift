import Common
import Swift
import WatchConnectivity

enum SessionState {
    case loggedIn
    case loggedOut
}

struct AppState {
    var activeFeedings: [Feeding] = []
    var timerPulseCount: Int = 0
    var sessionState: SessionState = .loggedOut
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
    case resume(Feeding)
}

let appReducer = combine(
    pullback(accountStatusReducer, keyValue: \.sessionState),
    pullback(pulseReducer, keyValue: \.timerPulseCount),
    pullback(communicationReducer, keyValue: \.didCommunicationFail),
    pullback(savedFyiDialogReducer, keyValue: \.showSavedFyiDialog),
    feedingReducer
)

func accountStatusReducer(sessinState: inout SessionState, action: AppAction) {
    switch action {
    // TODO: can logged out and logged in be combined?
    case .loggedIn:
       sessinState = .loggedIn
    case .loggedOut:
        sessinState = .loggedOut
    default:
        break
    }
}

func pulseReducer(timerPulseCount: inout Int, action: AppAction) {
    switch action {
    case .timerPulse:
        timerPulseCount += 1
    default:
        break
    }
}

// TODO: this should probably be a higher order reducer /w abstraced feeding reducer mutations
func communicationReducer(didCommunicationFail: inout Bool, action: AppAction) {
    switch action {
    case .clearFailedCommunication:
        didCommunicationFail = false
    default:
        break
    }
}

func savedFyiDialogReducer(showSavedFyiDialog: inout Bool, action: AppAction) {
    switch action {
    case .hideSavedFyiDialog:
        showSavedFyiDialog = false
    default:
        break
    }
}

// TODO: see what can be DRY-ed up here
func feedingReducer(value: inout AppState, action: AppAction) {
    switch action {
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
        // TODO: this should really be placed in the success block
        // from the communication above, but mutating the value in an
        // escaping block needs to be worked out. Can we send from the block?
        guard let i = value.activeFeedings.firstIndex(where: { $0.type == feeding.type }) else {
            value.didCommunicationFail = true
            return
        }
        value.activeFeedings[i].lastPausedDate = Date()
    case let .resume(feeding):
        let info = WatchCommunication(type: feeding.type,
                                      side: feeding.side,
                                      action: .resume)
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
        guard let i = value.activeFeedings.firstIndex(where: { $0.type == feeding.type }),
            let lpd = value.activeFeedings[i].lastPausedDate else {
            value.didCommunicationFail = true
            return
        }
        value.activeFeedings[i].pausedTime += abs(lpd.timeIntervalSinceNow)
        value.activeFeedings[i].lastPausedDate = nil
    default:
        break
    }
}
