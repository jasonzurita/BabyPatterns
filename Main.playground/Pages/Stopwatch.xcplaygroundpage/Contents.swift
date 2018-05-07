import UIKit
import PlaygroundSupport
@testable import Framework_BabyPatterns

let frame = CGRect(x: 0, y: 0, width: 350, height: 200)
let view = FeedingStopwatchView(feedingType: .nursing, frame: frame)
view.backgroundColor = .white

PlaygroundPage.current.liveView = view
