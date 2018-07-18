import Foundation
import Framework_BabyPatterns

extension FeedingsVM {
    // maybe overload ==
    func feedings(withTypes types: [FeedingType], isFinished: Bool) -> [Feeding] {
        return feedings.filter { types.contains($0.type) && $0.isFinished == isFinished }
    }

    func timeSinceLast(feedingTypes: [FeedingType]) -> TimeInterval {
        let finishedFeedings = feedings(withTypes: feedingTypes, isFinished: true)
        // TODO: consider returning some other value than sentinelish value
        guard let lastFeedingTime = finishedFeedings.last?.endDate else { return 0 }
        return abs(lastFeedingTime.timeIntervalSinceNow)
    }

    func lastFeedingSide(for type: FeedingType) -> FeedingSide {
        return feedings(withTypes: [type], isFinished: true).last?.side ?? .none
    }

    func averageNursingDuration(filterWindow _: DateInterval) -> TimeInterval? {
        let f = feedings(withTypes: [.nursing], isFinished: true)
        guard f.count > 0 else { return 0.0 }
        let sum = f.reduce(0.0, { $0 + $1.duration() })
        return sum / TimeInterval(f.count)
    }

    func lastFeeding(type: FeedingType) -> Feeding? {
        return feedings.filter { $0.type == type }.last
    }

    func remainingSupply() -> Double {
        return feedings.reduce(0.0, { runningTotal, feeding in
            runningTotal + feeding.supplyAmount
        })
    }
}
