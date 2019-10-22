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
    case session(SessionAction)
    case pulse(PulseAction)
    case communication(CommunicationAction)
    case savedFyiDialog(SavedFyiDialogAction)
    case feeding(FeedingAction)

    // TODO: consider auto-gen for this:
    // https://github.com/pointfreeco/swift-enum-properties
    var session: SessionAction? {
        get {
            guard case let .session(value) = self else { return nil }
            return value
        }
        set {
            guard case .session = self, let newValue = newValue else { return }
            self = .session(newValue)
        }
    }

    var pulse: PulseAction? {
        get {
            guard case let .pulse(value) = self else { return nil }
            return value
        }
        set {
            guard case .pulse = self, let newValue = newValue else { return }
            self = .pulse(newValue)
        }
    }

    var communication: CommunicationAction? {
        get {
            guard case let .communication(value) = self else { return nil }
            return value
        }
        set {
            guard case .communication = self, let newValue = newValue else { return }
            self = .communication(newValue)
        }
    }

    var savedFyiDialog: SavedFyiDialogAction? {
        get {
            guard case let .savedFyiDialog(value) = self else { return nil }
            return value
        }
        set {
            guard case .savedFyiDialog = self, let newValue = newValue else { return }
            self = .savedFyiDialog(newValue)
        }
    }

    var feeding: FeedingAction? {
        get {
            guard case let .feeding(value) = self else { return nil }
            return value
        }
        set {
            guard case .feeding = self, let newValue = newValue else { return }
            self = .feeding(newValue)
        }
    }
}

enum SessionAction {
    case loggedIn
    case loggedOut
}

enum PulseAction {
    case timerPulse
}

enum CommunicationAction {
    case clearFailedCommunication
}

enum SavedFyiDialogAction {
    case hideSavedFyiDialog
}

enum FeedingAction {
    case start(type: FeedingType, side: FeedingSide)
    case stop(Feeding)
    case pause(Feeding)
    case resume(Feeding)
}

let appReducer: (inout AppState, AppAction) -> Void  = combine(
    pullback(accountStatusReducer, value: \.sessionState, action: \.session),
    pullback(pulseReducer, value: \.timerPulseCount, action: \.pulse),
    pullback(communicationReducer, value: \.didCommunicationFail, action: \.communication),
    pullback(savedFyiDialogReducer, value: \.showSavedFyiDialog, action: \.savedFyiDialog),
    pullback(feedingReducer, value: \.self, action: \.feeding)
)

func accountStatusReducer(sessinState: inout SessionState, action: SessionAction) {
    switch action {
    // TODO: can logged out and logged in be combined?
    case .loggedIn:
       sessinState = .loggedIn
    case .loggedOut:
        sessinState = .loggedOut
    }
}

func pulseReducer(timerPulseCount: inout Int, action: PulseAction) {
    switch action {
    case .timerPulse:
        timerPulseCount += 1
    }
}

// TODO: this should probably be a higher order reducer /w abstraced feeding reducer mutations
func communicationReducer(didCommunicationFail: inout Bool, action: CommunicationAction) {
    switch action {
    case .clearFailedCommunication:
        didCommunicationFail = false
    }
}

func savedFyiDialogReducer(showSavedFyiDialog: inout Bool, action: SavedFyiDialogAction) {
    switch action {
    case .hideSavedFyiDialog:
        showSavedFyiDialog = false
    }
}

// TODO: see what can be DRY-ed up here
func feedingReducer(value: inout AppState, action: FeedingAction) {
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
    }
}
