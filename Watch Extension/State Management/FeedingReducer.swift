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
    case communicationFinished(Data?, Common.FeedingAction)
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
            WCSession.sendMessageDataPublisher(data: d)
                .compactMap { $0 }
                .replaceError(with: nil)
                .map { FeedingAction.communicationFinished($0, action) }
                .receive(on: DispatchQueue.main)
                .eraseToEffect(),
        ]
    case let .communicationFinished(data, feedingAction):
        guard data != nil else {
            feedingState.showCommunicationFyiDialog = true
            return []
        }

        defer { feedingState.isLoading = false }
        switch feedingAction {
        case .start: break
        case .stop: feedingState.showSavedFyiDialog = true
        case .pause: break
        case .resume: break
        }
        return []
    }
}
