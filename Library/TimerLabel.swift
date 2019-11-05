import Common
import UIKit

public protocol TimerSource {
    func duration() -> TimeInterval
    var isPaused: Bool { get }
}

public final class TimerLabel: UILabel {
    private let countingInterval: TimeInterval = 1
    private var _timer: Timer?
    public var activeSource: (() -> TimerSource?)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        start()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        start()
    }

    private func start() {
        refresh()

        _timer = Current.scheduledTimer(countingInterval, true) { [weak self] _ in
            // TODO: change all the `strongSelf` to `self` (in current Swift, `self` is now supported)
            guard let strongSelf = self else { return }
            strongSelf.refresh()
        }
    }

    public func refresh() {
        let source = activeSource?()
        if source?.isPaused ?? false {
            pulseAnimationIfNotPulsing()
        } else {
            layer.removeAllAnimations()
        }

        let duration = source?.duration() ?? 0

        // TODO: abstract this and put under test?
        let hours = duration.stringFromSecondsToHours(zeroPadding: true)
        let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: true)
        let seconds = minutes.remainder.stringFromSecondsToSeconds(zeroPadding: true)

        text = hours.string + ":" + minutes.string + ":" + seconds.string
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

    deinit {
        _timer?.invalidate()
    }
}
