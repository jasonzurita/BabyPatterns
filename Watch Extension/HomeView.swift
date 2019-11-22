import SwiftUI

/*
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
        .onAppear {
            self.store.send(.context(.requestFullContext))
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
