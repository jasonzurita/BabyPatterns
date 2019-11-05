import Foundation
import SwiftUI
import WatchKit

final class HostingController: WKHostingController<HomeView> {
    override var body: HomeView {
        HomeView()
    }
}
