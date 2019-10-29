import Common
import Swift

enum FeedingAction {
    case update(feedings: [Feeding])
}

func feedingReducer(value: inout [Feeding], action: FeedingAction) {
    switch action {
    case let .update(feedings):
        // TODO: show all after formatting the list view UI better
        value = feedings.filter { !$0.isFinished }
    }
}
