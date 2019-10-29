import SwiftUI

/*
 TODO: - V1 Watch
 - Polish UI
 - Allow watch to refresh feedings from main app
   + Refresh button? pull down? automatic?
 - Think about subscriptions or IAP for this
 */

struct HomeView: View {
    @ObservedObject var store: Store<AppState, AppAction> = {
        let s = Store(initialValue: AppState(),
                      reducer: appReducer)
        TimerPulse.shared.store = s
        TimerPulse.shared.start()

        SessionCoordinator.shared.store = s

        return s
    }()

    var body: some View {
        VStack {
            if store.value.sessionState == .loggedIn {
                LoggedInHomeView(store: store)
            } else {
                LoggedOutHomeView()
            }
        }
    }
}

// swiftlint:disable type_name
struct HomeView_Previews: PreviewProvider {
// swiftlint:enable type_name
    static var previews: some View {
        HomeView()
    }
}
