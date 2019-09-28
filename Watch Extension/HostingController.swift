import Foundation
import SwiftUI
import WatchKit

final class HostingController: WKHostingController<HomeView> {
    override var body: HomeView {
        // TODO: make sure we are logged in before showing this screen
        return HomeView()
    }
}
