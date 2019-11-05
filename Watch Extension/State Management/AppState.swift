import Common
import Swift

struct AppState {
    var activeFeedings: [Feeding] = []
    var timerPulseCount: Int = 0
    var sessionState: SessionState = .loggedOut
    // TODO: combine these into an enum?
    var showCommunicationErrorFyiDialog = false
    var showSavedFyiDialog = false
    var isLoading = false
}
