import SwiftUI

/*
 TODO: - V1 Watch
 - Polish UI
   + Look at putting nursing and side on left of the feeding chip
   + Try putting colored circle behind plus circle
   + Consider laceholder photo behind _no active feeding_ text
 V2
 - Have the feeding chip turn into pause and stop buttons instead of popup
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
