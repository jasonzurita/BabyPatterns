import UIKit

public final class TimerLabel: UILabel {
    private let countingInterval: Double = 1
    private var _timer: Timer?
    public var isPaused = false
    public var isRunning = false
    private var referenceDate = Date()
    private var counter: TimeInterval = 0 {
        didSet {
            let hours = counter.stringFromSecondsToHours(zeroPadding: true)
            let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: true)
            let seconds = minutes.remainder.stringFromSecondsToSeconds(zeroPadding: true)

            text = hours.string + ":" + minutes.string + ":" + seconds.string
        }
    }

    public func changeDisplayTime(time: TimeInterval) {
        guard !isRunning else {
            preconditionFailure("Timer wasn't stopped before trying to change time")
        }
        counter = time
    }

    public func start(startingAt startTime: TimeInterval) {
        guard _timer == nil else { return }
        isRunning = true

        counter = startTime
        referenceDate = Date(timeIntervalSinceNow: -startTime)

        _timer = Current.scheduledTimer(countingInterval, true, { [weak self] _ in
            guard let strongSelf = self else { return }
            guard !strongSelf.isPaused else {
                strongSelf.pulseAnimationIfNotPulsing()
                return
            }
            strongSelf.updateTimerCounterWithErrorCheck()
        })
    }

    /*
     This is to account for the internal counter falling out of sync
     with the actual started time; such as when the app gets suspended
     in the background.

     We cannot just use the `elapsedRefTime` because rounding errors
     make the displayed time a bit unstable, so the whole number `counter`
     is needed.
     */
    private func updateTimerCounterWithErrorCheck() {
        let elapsedRefTime = abs(referenceDate.timeIntervalSinceNow)
        let maxTimeDelta = 3.0
        if (elapsedRefTime - counter) > maxTimeDelta {
            counter = floor(elapsedRefTime)
        } else {
            counter += 1
        }
        print("ref counter: \(elapsedRefTime), counter: \(counter)")
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
