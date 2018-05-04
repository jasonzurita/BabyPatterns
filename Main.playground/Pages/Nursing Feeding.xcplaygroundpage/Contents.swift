import UIKit
import PlaygroundSupport
@testable import Framework_BabyPatterns


struct Controller: FeedingController {
    func start(feeding type: FeedingType, side: FeedingSide) {

    }
    func end(feeding type: FeedingType, side: FeedingSide) {

    }
    func pause(feeeding type: FeedingType, side: FeedingSide) {

    }
    func resume(feeding type: FeedingType, side: FeedingSide) {

    }
}
let c = Controller()
let vc = NursingVC(controller: c)

let parent = playgroundWrapper(child: vc,
                               device: .phone4inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)

PlaygroundPage.current.liveView = parent

print(vc.stopwatch)
