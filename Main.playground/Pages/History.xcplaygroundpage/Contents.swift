@testable import Framework_BabyPatterns
import PlaygroundSupport
import UIKit

UIFont.registerFonts

struct MockEvent: Event {
    let endDate: Date
    let type: FeedingType
    init(_ minutes: TimeInterval, _ type: FeedingType) {
        let date = Date(timeIntervalSinceNow: -minutes * 60)
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
    MockEvent(0, .nursing),
    MockEvent(60, .nursing),
    MockEvent(90, .nursing),
    MockEvent(120, .nursing),
    MockEvent(3 * 60, .bottle),
    MockEvent(4 * 60, .bottle),
    MockEvent(6 * 60, .bottle),
    MockEvent(12 * 60, .bottle),
    MockEvent(24 * 60, .pumping),
    MockEvent(60 * 60, .bottle),
    MockEvent(7 * 24 * 60, .nursing),
]

let summary = FeedingSummary()

let vc = HistoryVc(events: events, summary: summary)

let parent = playgroundWrapper(child: vc,
                               device: .phone4inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)
PlaygroundPage.current.liveView = parent
