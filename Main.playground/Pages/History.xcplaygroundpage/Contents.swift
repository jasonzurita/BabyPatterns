import UIKit
import PlaygroundSupport
@testable import Framework_BabyPatterns

struct MockEvent: Event {
    let endDate: Date
    init(_ minutes: TimeInterval) {
        let date = Date(timeIntervalSinceNow: -minutes * 60)
        endDate = date
    }
}

let events = [MockEvent(0),
              MockEvent(120),
              MockEvent(240),
              MockEvent(24*60),
              MockEvent(60*60),
              MockEvent(7*24*60)]

let vc = HistoryVC(events: events)

let parent = playgroundWrapper(child: vc, device: .phone4inch, orientation: .landscape, contentSizeCategory: .accessibilityMedium)
PlaygroundPage.current.liveView = parent
