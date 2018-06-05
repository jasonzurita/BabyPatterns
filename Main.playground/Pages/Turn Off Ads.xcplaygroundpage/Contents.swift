@testable import Framework_BabyPatterns
import PlaygroundSupport
import UIKit

let vc = TurnOffAdsVC()

let parent = playgroundWrapper(child: vc,
                               device: .phone4inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)

PlaygroundPage.current.liveView = parent
