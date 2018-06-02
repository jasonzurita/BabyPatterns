@testable import Framework_BabyPatterns
import PlaygroundSupport
import UIKit

let frame = CGRect(x: 0, y: 0, width: 400, height: 300)
let view = FeedingStopwatchView(feedingType: .nursing, frame: frame)
view.backgroundColor = .white

PlaygroundPage.current.liveView = view
