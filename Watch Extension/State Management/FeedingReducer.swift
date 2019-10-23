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
