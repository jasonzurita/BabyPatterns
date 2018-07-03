import Framework_BabyPatterns
import PlaygroundSupport
import UIKit

let vc = SignupVc()

let parent = playgroundWrapper(child: vc,
                               device: .phone4inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)
PlaygroundPage.current.liveView = parent
