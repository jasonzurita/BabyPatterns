import Common
import Swift

enum FeedingAction {
    case update(feedings: [Feeding])
}

func feedingReducer(value: inout [Feeding], action: FeedingAction) {
    switch action {
    case let .update(feedings):
        // TODO: show all after formatting the list view UI better
        // This will also reqire better handleing pause/resume/stop reducer actions
        value = feedings.filter { !$0.isFinished }
    }
}
