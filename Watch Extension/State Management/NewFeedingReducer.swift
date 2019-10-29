import Common
import Swift
import WatchConnectivity.WCSession

enum NewFeedingAction {
    case start(type: FeedingType, side: FeedingSide)
    case stop(type: FeedingType)
    case pause(type: FeedingType)
    case resume(type: FeedingType)
}

enum CommunicationAction {
    case clearFailedCommunication
}

// FIXME: fix the `didCommunicationFail` when coming from the main app
// if the watch doesn't have the incoming feeding to support the action
// the popup is shown and doesn't go away...
func newFeedingReducer(value: inout AppState, action: NewFeedingAction) {
    switch action {
    case let .start(type, side):
        let feeding = Feeding(type: type, side: side, startDate: Date(), supplyAmount: .zero)
        value.activeFeedings.append(feeding)
    case let .stop(type):
        guard let i = value.activeFeedings.firstIndex(where: { $0.type == type }) else {
//            value.didCommunicationFail = true
            return
        }
        let fipId = value.activeFeedings[i].id
        value.activeFeedings.removeAll { $0.id == fipId }
        value.showSavedFyiDialog = true
    case let .pause(type):
        guard let i = value.activeFeedings.firstIndex(where: { $0.type == type }) else {
//            value.didCommunicationFail = true
            return
        }
        value.activeFeedings[i].lastPausedDate = Date()
    case let .resume(type):
        guard let i = value.activeFeedings.firstIndex(where: { $0.type == type }),
            let lpd = value.activeFeedings[i].lastPausedDate else {
//            value.didCommunicationFail = true
            return
        }
        value.activeFeedings[i].pausedTime += abs(lpd.timeIntervalSinceNow)
        value.activeFeedings[i].lastPausedDate = nil
    }
}
