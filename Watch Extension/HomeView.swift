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
        ZStack {
            VStack {
                if store.value.sessionState == .loggedIn {
                    LoggedInHomeView(store:
                        store.view(
                            value: { $0.activeFeedings },
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

            if store.value.showCommunicationErrorFyiDialog {
                FyiDialog(text: Text("Oh no!\nPlease try again."),
                           screenWidthPercent: 0.75,
                           // TODO: need a red color
                           backgroundColor: Color.red,
                           displayDuration: 1.6,
                           endAction: { self.store.send(.communicationErrorFyiDialog(.hide)) })
            } else if store.value.showSavedFyiDialog {
                FyiDialog(text: Text("Saved!"),
                           screenWidthPercent: 0.5,
                           backgroundColor: .bpMediumGray,
                           displayDuration: 1.25,
                           endAction: { self.store.send(.fyiDialog(.hide)) })
            } else if store.value.isLoading {
                LoadingView()
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
