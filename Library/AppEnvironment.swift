import Swift

public var Current = AppEnvironment()

public struct AppEnvironment {
    public typealias ScheduledTimer = (TimeInterval, Bool, @escaping (Timer) -> Void) -> Timer
    public let scheduledTimer: ScheduledTimer
    public init(scheduledTimer: @escaping ScheduledTimer = Timer.scheduledTimer(withTimeInterval:repeats:block:)) {
        self.scheduledTimer = scheduledTimer
    }
}
