import Common
import Foundation

struct AppState {
    var activeFeedings: [Feeding] = []
    var timerPulseCount: Int = 0
    var sessionState: SessionState = .loggedOut
    // TODO: combine these into an enum?
    var showCommunicationErrorFyiDialog = false
    var showSavedFyiDialog = false
    var isLoading = false

    static var singleFeedingMock: AppState {
        let feeding = Feeding(type: .nursing,
                              side: .left,
                              startDate: Date() - 3355,
                              supplyAmount: .zero,
                              pausedTime: 0)
        return AppState(activeFeedings: [feeding],
                        timerPulseCount: 2,
                        sessionState: .loggedIn,
                        showCommunicationErrorFyiDialog: false,
                        showSavedFyiDialog: false,
                        isLoading: false)
    }
}
