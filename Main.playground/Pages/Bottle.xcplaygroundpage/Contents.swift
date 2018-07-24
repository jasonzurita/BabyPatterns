import Framework_BabyPatterns
import PlaygroundSupport
import UIKit

UIFont.registerFonts

final class MockBottleProvider: BottleDelegate, BottleDataSource {
    init() {}

    var supply = SupplyAmount(value: 2500)
    var maxSupply = SupplyAmount(value: 5000)

    func logBottleFeeding(withAmount amount: Int, time: Date) {
        let newSupply = supply.value - amount
        supply = SupplyAmount(value: newSupply)
        print("Amount: \(amount), Time: \(time)")
    }

    func remainingSupply() -> SupplyAmount {
        return supply
    }

    func desiredMaxSupply() -> SupplyAmount {
        return maxSupply
    }
}

let provider = MockBottleProvider()

let vc = BottleVC()
vc.dataSource = provider
vc.delegate = provider

let parent = playgroundWrapper(child: vc,
                               device: .phone5_5inch,
                               orientation: .portrait,
                               contentSizeCategory: .accessibilityMedium)

PlaygroundPage.current.liveView = parent
