import Common
import Foundation

// TODO: this should be combined (or sorted out) with the iOS app's Feeding struct
struct Feeding: Identifiable {
    let id = UUID()
    let start: Date
    let type: FeedingType
    let side: FeedingSide
    var lastPausedDate: Date?
    var pausedTime: TimeInterval = 0

    var isPaused: Bool {
        lastPausedDate != nil
    }

    func duration() -> TimeInterval {
        return round(abs(start.timeIntervalSinceNow) - fullPausedTime())
    }

    private func fullPausedTime() -> TimeInterval {
        var adjustment: TimeInterval = 0.0
        if let lastPausedDate = lastPausedDate {
            adjustment = abs(lastPausedDate.timeIntervalSinceNow)
        }
        return pausedTime + adjustment
    }
}
