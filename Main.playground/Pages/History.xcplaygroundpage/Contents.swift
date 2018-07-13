@testable import Framework_BabyPatterns
import PlaygroundSupport
import UIKit

UIFont.registerFonts

struct MockEvent: Event {
    let endDate: Date
    init(_ minutes: TimeInterval) {
        let date = Date(timeIntervalSinceNow: -minutes * 60)
        endDate = date
    }
}

struct FeedingSummary: FeedingSummaryProtocol {
    let timeSinceLastNursing: TimeInterval
    let lastNursingSide: FeedingSide
    let averageNursingDuration: TimeInterval
    let timeSinceLastPumping: TimeInterval
    let lastPumpingSide: FeedingSide
    let lastPumpedAmount: Double
    let timeSinceLastBottleFeeding: TimeInterval
    let remainingSupplyAmount: Double
}

let events = [
    MockEvent(0),
    MockEvent(120),
    MockEvent(240),
    MockEvent(12 * 60),
    MockEvent(24 * 60),
    MockEvent(60 * 60),
    MockEvent(7 * 24 * 60),
]

let summary = FeedingSummary(timeSinceLastNursing: 60,
                             lastNursingSide: .left,
                             averageNursingDuration: 100,
                             timeSinceLastPumping: 120,
                             lastPumpingSide: .right,
                             lastPumpedAmount: 100,
                             timeSinceLastBottleFeeding: 1000,
                             remainingSupplyAmount: 100)

let vc = HistoryVc(events: events, summary: summary)

let parent = playgroundWrapper(child: vc,
                               device: .phone4inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)
PlaygroundPage.current.liveView = parent
