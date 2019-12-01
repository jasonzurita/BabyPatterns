import SwiftUI

/*
 V2
 - Have the feeding chip turn into pause and stop buttons instead of popup
 */

struct HomeView: View {
    @ObservedObject var store: Store<AppState, AppAction> = {
        let s = Store(initialValue: AppState(),
                      reducer: appReducer)
        TimerPulse.shared.store = s.view(value: { _ in }, action: { .pulse($0) })
        TimerPulse.shared.start()

        SessionCoordinator.shared.store = s.view(
            value: { _ in },
            action: {
                switch $0 {
                case let .session(action): return.session(action)
                case let .context(action): return .context(action)
                case let .feeding(action): return.feeding(action)
                }
            }
        )

        return s
    }()

    var body: some View {
        VStack {
            if store.value.sessionState == .loggedIn {
                LoggedInHomeView(store:
                    store.view(
                        value: {
                        ($0.activeFeedings,
                         $0.showCommunicationErrorFyiDialog,
                         $0.showSavedFyiDialog,
                         $0.isLoading)
                        },
                        action: {
                            switch $0 {
                            case let .communicationErrorFyiDialog(action):
                                return .communicationErrorFyiDialog(action)
                            case let .fyiDialog(action):
                                return .fyiDialog(action)
                            case let .loading(action):
                                return .loading(action)
                            }
                        }
                    )
                )
            } else {
                LoggedOutHomeView(store:
                    store.view(
                        value: { _ in },
                        action: { .context($0) }
                    )
                )
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
