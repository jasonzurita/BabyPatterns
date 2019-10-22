import Swift

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
enum FeedingAction {
    case start(type: FeedingType, side: FeedingSide)
    case stop(Feeding)
    case pause(Feeding)
    case resume(Feeding)
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
