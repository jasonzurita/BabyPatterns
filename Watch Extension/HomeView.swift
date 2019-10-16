import SwiftUI

/*
 TODO: - V1 Watch
 - Polish UI
 - Handle UI when main app manages an in-progress feeding
 - Get pause to actually pause
 - Make sure a backgrounded/terminated main app
   behaves well from a UI standpoint when using the watch
 - Think about subscriptions or IAP for this
 - Load all feedings when starting up?
 - What to do with bottle feeding?
 */

struct HomeView: View {
    @ObservedObject var store: Store<AppState, AppAction> = {
        let s = Store(initialValue: AppState(), reducer: appReducer)
        TimerPulse.shared.store = s
        TimerPulse.shared.start()

        SessionCoordinator.shared.store = s

        return s
    }()

    var body: some View {
        VStack {
            if store.value.session == .loggedIn {
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
