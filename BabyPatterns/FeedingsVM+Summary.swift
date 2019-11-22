import Common
import Foundation
import Framework_BabyPatterns

extension FeedingsVM {
    // maybe overload ==
    func feedings(withTypes types: [FeedingType], isFinished: Bool) -> [Feeding] {
        return feedings.filter { types.contains($0.type) && $0.isFinished == isFinished }
    }

    func timeSinceLastFeedingStart(for feedingTypes: [FeedingType]) -> TimeInterval {
        let finishedFeedings = feedings(withTypes: feedingTypes, isFinished: true)
        // TODO: consider returning some other value than sentinelish value
        guard let lastFeedingTime = finishedFeedings.last?.startDate else { return 0 }
        return abs(lastFeedingTime.timeIntervalSinceNow)
    }

    func lastFeedingSide(for type: FeedingType) -> FeedingSide {
        return feedings(withTypes: [type], isFinished: true).last?.side ?? .none
    }

    func averageNursingDuration(filterWindow: DateInterval) -> TimeInterval {
        let f = feedings(withTypes: [.nursing], isFinished: true).filter {
            guard let end = $0.endDate else { return false }
            return filterWindow.contains(end)
        }
        guard !f.isEmpty else { return 0.0 }
        // TODO: this could probably be a map {$0.duration()}.reduce(0, +) to make it easier to read
        let sum = f.reduce(0.0) { $0 + $1.duration() }
        return sum / TimeInterval(f.count)
    }

    func lastFeeding(type: FeedingType) -> Feeding? {
        return feedings.filter { $0.type == type }.last
    }

    func remainingSupply() -> SupplyAmount {
        let total = feedings.reduce(0, { runningTotal, feeding in
            runningTotal + feeding.supplyAmount.value
        })
        return SupplyAmount(value: total)
    }
}
