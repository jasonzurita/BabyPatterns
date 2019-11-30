import Common
import Foundation

final class TimerPulse {
    // TODO: need to manage the timer by hooking into the app's lifecycle
    static let shared = TimerPulse()

    var store: Store<Void, PulseAction>?
    private var timer: Timer?

    func start() {
        // TODO: add this timer to a background runloop to avoid this
        // stopping when UI is moving. This is because by default,
        // a new timer is added to the main runloop (aka the main thread)
        timer = Current.scheduledTimer(1, true) { [weak self] _ in
            guard let self = self else { return }
            self.store?.send(.timerPulse)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
