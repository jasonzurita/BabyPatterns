@testable import Framework_BabyPatterns
import PlaygroundSupport
import UIKit

UIFont.registerFonts

struct MockEvent: Event {
    let endDate: Date
    let type: FeedingType
    init(hours: TimeInterval, _ type: FeedingType) {
        let date = Date(timeIntervalSinceNow: -hours * 60 * 60)
        endDate = date
        self.type = type
    }
}

let amount = SupplyAmount(value: 2550)

struct FeedingSummary: FeedingSummaryProtocol {
    let timeSinceLastNursing: TimeInterval = 60
    let lastNursingSide: FeedingSide = .left
    let averageNursingDuration: TimeInterval = 100
    let timeSinceLastPumping: TimeInterval = 120
    let lastPumpingSide: FeedingSide = .right
    let lastPumpedAmount: SupplyAmount = amount
    let timeSinceLastBottleFeeding: TimeInterval = 1000
    let remainingSupplyAmount: SupplyAmount = amount
    let desiredSupplyAmount: SupplyAmount = amount
}

let events = [
    MockEvent(hours: 0, .nursing),
    MockEvent(hours: 1, .nursing),
    MockEvent(hours: 1.5, .nursing),
    MockEvent(hours: 2, .nursing),
    MockEvent(hours: 3, .bottle),
    MockEvent(hours: 4, .bottle),
    MockEvent(hours: 6, .bottle),
    MockEvent(hours: 12, .bottle),
    MockEvent(hours: 24, .pumping),
    MockEvent(hours: 60, .bottle),
    MockEvent(hours: 7 * 24, .nursing),
]

let summary = FeedingSummary()

let vc = HistoryVc(events: events, summary: summary)

let parent = playgroundWrapper(child: vc,
                               device: .phone4inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)
PlaygroundPage.current.liveView = parent
