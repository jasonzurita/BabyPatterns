import Common
import Swift

struct AppState {
    var activeFeedings: [Feeding] = []
    var timerPulseCount: Int = 0
    var sessionState: SessionState = .loggedOut
    var didCommunicationFail = false
    /*
     TODO: think about this some more.
     I am not too sure how much I like this.
     It is a bit of a weird side effect, but for now
     it gets the job done.
     */
    var showSavedFyiDialog = false
}
