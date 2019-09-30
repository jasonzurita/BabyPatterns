import Common
import Library
import UIKit

public final class FeedingStopwatchView: UIView {
    typealias StatusChangeHandler = ((FeedingType, FeedingSide) -> Void)
    var onStart: StatusChangeHandler?
    var onEnd: StatusChangeHandler?
    var onPause: StatusChangeHandler?
    var onResume: StatusChangeHandler?

    var lastFeedingSide: FeedingSide = .none {
        didSet {
            switch lastFeedingSide {
            case .none:
                if !leftFeedingControl.isActive {
                    leftFeedingControl.setTitle("Left", for: .normal)
                }
                if !rightFeedingControl.isActive {
                    rightFeedingControl.setTitle("Right", for: .normal)
                }
            case .left:
                leftFeedingControl.setTitle("Left*", for: .normal)
            case .right:
                rightFeedingControl.setTitle("Right*", for: .normal)
            }
        }
    }

    private let _feedingType: FeedingType
    private var _sideInProgress: FeedingSide = .none

    private var _activeControl: FeedingControl? {
        switch (leftFeedingControl.isActive, rightFeedingControl.isActive) {
        case (true, false):
            return leftFeedingControl
        case (false, true):
            return rightFeedingControl
        case (true, true):
            assertionFailure("Both feeding controls are active. How!?")
            return nil
        case (false, false):
            return nil
        }
    }

    @IBOutlet var view: UIView! {
        didSet {
            view.frame = bounds
            addSubview(view)
        }
    }

    @IBOutlet var timerLabel: TimerLabel! {
        didSet {
            timerLabel.changeDisplayTime(time: 0)
            styleLabelTimer(timerLabel)
        }
    }

    @IBOutlet var leftFeedingControl: FeedingControl! {
        didSet {
            leftFeedingControl.side = .left
            styleButtonFont(.notoSansRegular(ofSize: 16))(leftFeedingControl)
        }
    }

    @IBOutlet var rightFeedingControl: FeedingControl! {
        didSet {
            rightFeedingControl.side = .right
            styleButtonFont(.notoSansRegular(ofSize: 16))(rightFeedingControl)
        }
    }

    private lazy var stopButton: StopButton = {
        let onTap: () -> Void = { [weak self] in
            self?.stopButtonPressed()
        }
        return StopButton(onTap: onTap, enabledColor: .bpDarkGray, disabledColor: .bpLightGray)
    }()

    @IBOutlet var stopButtonContainerView: UIView! {
        didSet {
            stopButtonContainerView.addSubview(stopButton)
            stopButton.bindFrameToSuperviewBounds()
        }
    }

    public init(feedingType: FeedingType, frame: CGRect = .zero) {
        _feedingType = feedingType

        super.init(frame: frame)
        loadNib()

        stopButton.isDisabled = true
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    func stopButtonPressed() {
        guard timerLabel.isRunning else {
            preconditionFailure("Cannot stop timer that is not running")
        }

        guard _sideInProgress != .none else {
            preconditionFailure("No side in progress to stop")
        }

        var control: FeedingControl!
        if leftFeedingControl.isActive && _sideInProgress == .left {
            control = leftFeedingControl
        } else if rightFeedingControl.isActive && _sideInProgress == .right {
            control = rightFeedingControl
        } else {
            assertionFailure("Failed to end feeding")
        }
        reset(control: control)
        onEnd?(_feedingType, _sideInProgress)
        lastFeedingSide = _sideInProgress
        _sideInProgress = .none
    }

    @IBAction func feedingButtonPressed(_ sender: FeedingControl) {
        guard sender.side != .none else {
            preconditionFailure("Cannot start / end feeding because no feeding type or no side")
        }

        // TODO: make into enum
        let shouldStartTimer = !timerLabel.isRunning && !timerLabel.isPaused
        let shouldPauseTimer = timerLabel.isRunning && !timerLabel.isPaused && sender.isActive
        let shouldResumeTimer = timerLabel.isRunning && timerLabel.isPaused && sender.isActive

        if shouldStartTimer {
            startFeeding(at: 0, on: sender.side)
            onStart?(_feedingType, sender.side)
        } else if shouldPauseTimer {
            pause()
            onPause?(_feedingType, sender.side)
        } else if shouldResumeTimer {
            resumeFeeding(control: sender)
            onResume?(_feedingType, sender.side)
        }
    }

    func startFeeding(at startTime: TimeInterval, on side: FeedingSide) {
        var control: FeedingControl?
        switch side {
        case .left:
            control = leftFeedingControl
        case .right:
            control = rightFeedingControl
        case .none:
            assertionFailure("Asked to start a feeding on side of = none")
        }
        timerLabel.start(at: TimerLabel.Seconds(startTime))
        timerLabel.resume()
        control!.setTitle("Pause", for: .normal)
        control!.isActive = true
        stopButton.isDisabled = false
        _sideInProgress = control!.side
        // this should be at the end for the feeding title to work properly
        lastFeedingSide = .none
    }

    func pause() {
        guard let control = _activeControl else { return }
        timerLabel.pause()
        control.setTitle("Resume", for: .normal)
    }

    private func resumeFeeding(control: FeedingControl) {
        timerLabel.resume()
        control.setTitle("Pause", for: .normal)
    }

    private func reset(control: FeedingControl) {
        control.isActive = false
        stopButton.isDisabled = true
        timerLabel.end()
    }
}
