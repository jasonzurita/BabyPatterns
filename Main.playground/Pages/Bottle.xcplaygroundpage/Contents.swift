import Framework_BabyPatterns
import PlaygroundSupport
import UIKit

final class MockBottleProvider: BottleDelegate, BottleDataSource {
    init() {}

    var supply = 25.0
    var maxSupply = 50.0

    func logBottleFeeding(withAmount amount: Double, time: Date) {
        supply -= amount
        print("Amount: \(amount), Time: \(time)")
    }

    func remainingSupply() -> Double {
        return supply
    }

    func desiredMaxSupply() -> Double {
        return maxSupply
    }
}

let provider = MockBottleProvider()

UIFont.registerFonts

let vc = BottleVC()
vc.dataSource = provider
vc.delegate = provider

let parent = playgroundWrapper(child: vc,
                               device: .phone5_5inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)

PlaygroundPage.current.liveView = parent
