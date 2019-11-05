import Common
import Library
import UIKit

// Done to be able to pass feeding into the timer label
extension Feeding: TimerSource {}

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

    var feedingInProgress: ((FeedingType) -> Feeding?)?

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
            timerLabel.activeSource = { [weak self] in
                guard let self = self else { return nil }
                return self.feedingInProgress?(self._feedingType)
            }
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
        guard _sideInProgress != .none else {
            preconditionFailure("No side in progress to stop")
        }

        onEnd?(_feedingType, _sideInProgress)
        reset(lastFeedingSide: _sideInProgress)
        _sideInProgress = .none
    }

    @IBAction func feedingButtonPressed(_ sender: FeedingControl) {
        guard sender.side != .none else {
            preconditionFailure("Cannot start / end feeding because no feeding type or no side")
        }

        defer { timerLabel.refresh() }

        if let fip = feedingInProgress?(_feedingType) {
            if fip.isPaused {
                sender.setTitle("Pause", for: .normal)
                onResume?(_feedingType, sender.side)
            } else {
                if let control = _activeControl {
                    control.setTitle("Resume", for: .normal)
                }
                onPause?(_feedingType, sender.side)
            }
        } else {
            onStart?(_feedingType, sender.side)
            updateUIForInProgressFeeding(on: sender.side)
        }
    }

    func updateUIForInProgressFeeding(on side: FeedingSide) {
        var control: FeedingControl! // ! is okay here b/c of below switch
        switch side {
        case .left:
            control = leftFeedingControl
        case .right:
            control = rightFeedingControl
        case .none:
            assertionFailure("Asked to start a feeding on side of = none")
        }

        if let fip = feedingInProgress?(_feedingType), !fip.isPaused {
            control.setTitle("Pause", for: .normal)
        } else {
            control.setTitle("Resume", for: .normal)
        }

        control.isActive = true
        stopButton.isDisabled = false
        _sideInProgress = control.side
        // this should be at the end for the feeding title to work properly
        lastFeedingSide = .none
    }

    func reset(lastFeedingSide: FeedingSide) {
        leftFeedingControl.isActive = false
        rightFeedingControl.isActive = false
        stopButton.isDisabled = true
        self.lastFeedingSide = lastFeedingSide
    }
}
