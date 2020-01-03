import Common
import Cycle
import Swift
import WatchConnectivity

typealias FeedingState = (
    feedings: [Feeding],
    showCommunicationFyiDialog: Bool,
    showSavedFyiDialog: Bool,
    isLoading: Bool
)

enum FeedingAction {
    case update(feedings: [Feeding])
    case communicate(type: FeedingType, side: FeedingSide, action: Common.FeedingAction)
    case communicationFailed
    case showFeedingStopped
    case loadingFinished
}

func feedingReducer(feedingState: inout FeedingState, action: FeedingAction) -> [Effect<FeedingAction>] {
    switch action {
    case let .update(feedings):
        // TODO: show all after formatting the list view UI better
        // This will also reqire better handleing pause/resume/stop reducer actions
        feedingState.feedings = feedings.filter { !$0.isFinished }
        return []
    case let .communicate(type, side, action):
        let info = WatchFeedingCommunication(type: type, side: side, action: action)
        let jsonEncoder = JSONEncoder()
        guard let d = try? jsonEncoder.encode(info), WCSession.default.isReachable else {
            feedingState.showCommunicationFyiDialog = true
            return []
        }
        feedingState.isLoading = true
        return [
            Effect { callback in
                WCSession.default.sendMessageData(
                    d,
                    replyHandler: { _ in
                        defer { callback(.loadingFinished) }
                        switch action {
                        case .start: break
                        case .stop: callback(.showFeedingStopped)
                        case .pause: break
                        case .resume: break
                        }
                },
                    errorHandler: { error in
                        print("Error sending the message: \(error.localizedDescription)")
                        callback(.communicationFailed)
                })
            },
        ]
    case .communicationFailed:
        feedingState.showCommunicationFyiDialog = true
        return []
    case .showFeedingStopped:
        feedingState.showSavedFyiDialog = true
        return []
    case .loadingFinished:
        feedingState.isLoading = false
        return []
    }
}
