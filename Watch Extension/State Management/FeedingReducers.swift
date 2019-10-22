import Common
import Swift
import WatchConnectivity.WCSession

enum FeedingAction {
    case start(type: FeedingType, side: FeedingSide)
    case stop(Feeding)
    case pause(Feeding)
    case resume(Feeding)
}

enum CommunicationAction {
    case clearFailedCommunication
}

/*
 TODO: This higher order reducer and feeding reducer should be flipped where
 the send message reducer below is first called, feeding is labeled (enum?) as
 pending (w/ UI to show that) and then the response to the send dictates if we call
 the local feeding management reducers to show the ticking time, etc. This will better
 help when trying handle a communication situation.
 */
func higherOrderFeedingCommunicationReducer(
    _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        func sendMessage(info: WatchCommunication) {
            let jsonEncoder = JSONEncoder()
            guard let d = try? jsonEncoder.encode(info), WCSession.default.isReachable else {
                state.didCommunicationFail = true
                return
            }

            WCSession.default.sendMessageData(d, replyHandler: nil) { error in
                // TODO: should gracefully handle a failure here
                print("Error sending the message: \(error.localizedDescription)")
                assertionFailure()
            }
        }

        switch action {
        // TODO: evaluate the name `communication`
        case .session, .pulse, .savedFyiDialog:
            break
        case .communication(.clearFailedCommunication):
            state.didCommunicationFail = false
        case let .feeding(.start(type, side)):
            sendMessage(info: WatchCommunication(type: type, side: side, action: .start))
        case let .feeding(.pause(feeding)):
            sendMessage(info: WatchCommunication(type: feeding.type, side: feeding.side, action: .pause))
        case let .feeding(.resume(feeding)):
            sendMessage(info: WatchCommunication(type: feeding.type, side: feeding.side, action: .resume))
        case let .feeding(.stop(feeding)):
            sendMessage(info: WatchCommunication(type: feeding.type, side: feeding.side, action: .stop))
        }
        reducer(&state, action)
    }
}

func feedingReducer(value: inout AppState, action: FeedingAction) {
    switch action {
    case let .start(type, side):
        let feeding = Feeding(start: Date(), type: type, side: side)
        value.activeFeedings.append(feeding)
    case let .stop(feeding):
        value.activeFeedings.removeAll { $0.id == feeding.id }
        value.showSavedFyiDialog = true
    case let .pause(feeding):
        guard let i = value.activeFeedings.firstIndex(where: { $0.type == feeding.type }) else {
            value.didCommunicationFail = true
            return
        }
        value.activeFeedings[i].lastPausedDate = Date()
    case let .resume(feeding):
        guard let i = value.activeFeedings.firstIndex(where: { $0.type == feeding.type }),
            let lpd = value.activeFeedings[i].lastPausedDate else {
            value.didCommunicationFail = true
            return
        }
        value.activeFeedings[i].pausedTime += abs(lpd.timeIntervalSinceNow)
        value.activeFeedings[i].lastPausedDate = nil
    }
}
