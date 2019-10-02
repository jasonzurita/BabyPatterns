import Common
import Swift
import WatchConnectivity

struct AppState {
    var activeFeedings: [Date] = []
}

enum AppAction {
    case start(type: FeedingType, side: FeedingSide)
    case stop
    case pause
}

func appReducer(value: inout AppState, action: AppAction) {
    switch action {
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
        value.activeFeedings.append(Date())
    case .stop:
        break
    case .pause:
        break
    }
}
