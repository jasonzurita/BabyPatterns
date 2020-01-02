import Swift
import Cycle

enum PulseAction {
    case timerPulse
}

func pulseReducer(timerPulseCount: inout Int, action: PulseAction) -> [Effect<PulseAction>] {
    switch action {
    case .timerPulse:
        timerPulseCount += 1
        return []
    }
}
