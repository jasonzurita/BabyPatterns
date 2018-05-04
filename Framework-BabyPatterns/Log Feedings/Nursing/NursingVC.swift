import UIKit

public protocol FeedingController {
    func start(feeding type: FeedingType, side: FeedingSide)
    func end(feeding type: FeedingType, side: FeedingSide)
    func pause(feeeding type: FeedingType, side: FeedingSide)
    func resume(feeding type: FeedingType, side: FeedingSide)
}

public final class NursingVC: UIViewController {

    let stopwatch = FeedingStopwatchView(feedingType: .nursing)

    public init(controller: FeedingController) {
        super.init(nibName: nil, bundle: nil)
        stopwatch.onStart = { type, side in

        }

        stopwatch.onEnd = { type, side in

        }

        stopwatch.onPause = { type, side in

        }

        stopwatch.onResume = { type, side in

        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        view = UIView()

        view.addSubview(stopwatch)
        stopwatch.backgroundColor = .yellow

        NSLayoutConstraint.activate([
            stopwatch.topAnchor.constraint(equalTo: view.topAnchor),
            stopwatch.widthAnchor.constraint(equalTo: view.widthAnchor),
            stopwatch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])

        stopwatch.dataSource = self
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resumeFeedingIfNeeded()
    }

    private func resumeFeedingIfNeeded() {
//        guard let lf = dataSource?.lastFeeding(type: feedingType), !lf.isFinished else {
//            timerLabel.changeDisplayTime(time: 0)
//            return
//        }
//
//        guard let control = lf.side == .left ? leftFeedingControl : rightFeedingControl else {
//            log("No active control to resume feeding with", object: self, type: .error)
//            return
//        }
//        resumeFeeding(feedingInProgress: lf, activeControl: control)
    }

    private func resumeFeeding(feedingInProgress: Feeding, activeControl: FeedingControl) {
//        startFeeding(control: activeControl, startTime: feedingInProgress.duration())
//        if feedingInProgress.isPaused {
//            pauseFeeding(control: activeControl)
//        }
    }
}

extension NursingVC: FeedingStopwatchDataSource {
    public func currentFeedingDuration() -> TimeInterval? {
        return nil
    }
}
