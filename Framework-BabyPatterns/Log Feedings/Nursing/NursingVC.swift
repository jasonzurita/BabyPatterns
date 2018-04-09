import UIKit

public final class NursingVC: UIViewController {

    let stopwatch = FeedingStopwatchView(feedingType: .nursing)

    public init() {
        super.init(nibName: nil, bundle: nil)
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

        stopwatch.delegate = self
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

extension NursingVC: FeedingStopWatchDelegate {
    public func start(feeding type: FeedingType, side: FeedingSide) {
        // do work!
    }

    public func end(feeding type: FeedingType, side: FeedingSide) {
        // do work!
    }

    public func pause(feeeding type: FeedingType, side: FeedingSide) {
        // do work!
    }

    public func resume(feeding type: FeedingType, side: FeedingSide) {
        // do work!
    }
}

extension NursingVC: FeedingStopwatchDataSource {
    public func currentFeedingDuration() -> TimeInterval? {
        return nil
    }
}
