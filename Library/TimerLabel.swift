import UIKit

public final class TimerLabel: UILabel {
    public typealias Seconds = Int
    private let countingInterval: Double = 1
    private var _timer: Timer?
    public var isPaused = false
    public var isRunning = false
    private var referenceDate = Date()

    private var counter: Seconds = 0 {
        didSet {
            // TODO: abstract this and put under test?
            let hours = TimeInterval(counter).stringFromSecondsToHours(zeroPadding: true)
            let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: true)
            let seconds = minutes.remainder.stringFromSecondsToSeconds(zeroPadding: true)

            text = hours.string + ":" + minutes.string + ":" + seconds.string
        }
    }

    public func changeDisplayTime(time: Seconds) {
        guard !isRunning else {
            preconditionFailure("Timer wasn't stopped before trying to change time")
        }
        counter = time
    }

    public func start(at startTime: Seconds) {
        guard _timer == nil else { return }
        isRunning = true

        counter = startTime
        referenceDate = Date(timeIntervalSinceNow: -TimeInterval(startTime))

        _timer = Current.scheduledTimer(countingInterval, true) { [weak self] _ in
            // TODO: change all the `strongSelf` to `self` (in current Swift, `self` is now supported)
            guard let strongSelf = self else { return }
            guard !strongSelf.isPaused else {
                strongSelf.pulseAnimationIfNotPulsing()
                return
            }
            strongSelf.counter += 1
            // TODO: improve logging, so this isn't in production
            print("counter: \(strongSelf.counter)")
        }
    }

    public func end() {
        guard let t = _timer else { return }
        isRunning = false
        isPaused = false
        clearPauseAnimation()
        t.invalidate()
        _timer = nil
        changeDisplayTime(time: 0)
    }

    public func pause() {
        guard _timer != nil else { return }
        isPaused = true
        pulseAnimationIfNotPulsing()
    }

    private func pulseAnimationIfNotPulsing() {
        guard layer.animationKeys() == nil else { return }
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.autoreverse, .curveEaseInOut, .repeat],
                       animations: {
                           self.alpha = 0.0
                       }, completion: { [weak self] _ in
                           guard let strongSelf = self else { return }
                           strongSelf.alpha = 1.0
        })
    }

    public func resume() {
        guard _timer != nil else { return }
        isPaused = false
        clearPauseAnimation()
    }

    private func clearPauseAnimation() {
        layer.removeAllAnimations()
    }

    deinit {
        _timer?.invalidate()
    }
}
