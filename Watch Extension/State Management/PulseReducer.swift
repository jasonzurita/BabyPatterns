import Swift

enum PulseAction {
    case timerPulse
}

func pulseReducer(timerPulseCount: inout Int, action: PulseAction) {
    switch action {
    case .timerPulse:
        timerPulseCount += 1
    }
}
