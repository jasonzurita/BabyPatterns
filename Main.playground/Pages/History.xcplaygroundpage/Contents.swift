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
    let timeSinceLastNursing: TimeInterval = 60
    let lastNursingSide: FeedingSide = .left
    let averageNursingDuration: TimeInterval = 100
    let timeSinceLastPumping: TimeInterval = 120
    let lastPumpingSide: FeedingSide = .right
    let lastPumpedAmount: Double = 100
    let timeSinceLastBottleFeeding: TimeInterval = 1000
    let remainingSupplyAmount: Double = 50
    let desiredSupplyAmount: Double = 100
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

let summary = FeedingSummary()

let vc = HistoryVc(events: events, summary: summary)

let parent = playgroundWrapper(child: vc,
                               device: .phone4inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)
PlaygroundPage.current.liveView = parent
