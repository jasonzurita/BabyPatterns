import UIKit
import PlaygroundSupport
@testable import Framework_BabyPatterns

let vc = NursingVC()

let parent = playgroundWrapper(child: vc,
                               device: .phone4inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)

PlaygroundPage.current.liveView = parent

print(vc.stopwatch)
