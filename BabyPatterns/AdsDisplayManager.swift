import Framework_BabyPatterns
import Firebase
import UIKit

struct AdsDisplayManager {
    private var didRequestAds = false

    mutating func update(_ bannerView: GADBannerView,
                         for state: AdsDisplayState,
                         additionalViewsToManage additionalViews: [UIView] = []) {
        switch state {
        case .initialInstall, .show:
            if didRequestAds {
                bannerView.isHidden = false
                additionalViews.forEach { $0.isHidden = false }
            } else {
                loadAds(for: bannerView)
                didRequestAds = true
            }
        case .hide:
            bannerView.isHidden = true
            additionalViews.forEach { $0.isHidden = true }
        }
    }

    private func loadAds(for bannerView: GADBannerView) {
        let adRequest = GADRequest()
        adRequest.testDevices = [kGADSimulatorID, "4796a5487323e9b9f16cf3dd3c0ada73"]
        bannerView.load(adRequest)
    }
}
