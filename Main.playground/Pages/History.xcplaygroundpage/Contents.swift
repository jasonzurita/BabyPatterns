import UIKit
import PlaygroundSupport
import Framework_BabyPatterns


let vc = HistoryVC()

let parent = playgroundWrapper(child: vc, device: .phone4inch, orientation: .landscape, contentSizeCategory: .accessibilityExtraExtraExtraLarge)
PlaygroundPage.current.liveView = parent

