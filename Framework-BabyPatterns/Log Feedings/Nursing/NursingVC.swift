import UIKit

public protocol FeedingController {
    func start(feeding type: FeedingType, side: FeedingSide)
    func end(feeding type: FeedingType, side: FeedingSide)
    func pause(feeeding type: FeedingType, side: FeedingSide)
    func resume(feeding type: FeedingType, side: FeedingSide)
}

public final class NursingVC: UIViewController {

    private let _stopwatch = FeedingStopwatchView(feedingType: .nursing)

    public init(controller: FeedingController) {
        super.init(nibName: nil, bundle: nil)
        _stopwatch.onStart = controller.start(feeding:side:)
        _stopwatch.onEnd = controller.end(feeding:side:)
        _stopwatch.onPause = controller.pause(feeeding:side:)
        _stopwatch.onResume = controller.resume(feeding:side:)
    }
    
    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    public override func loadView() {
        super.loadView()
        view = UIView()

        view.addSubview(_stopwatch)

        _stopwatch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _stopwatch.topAnchor.constraint(equalTo: view.topAnchor),
            _stopwatch.widthAnchor.constraint(equalTo: view.widthAnchor),
            _stopwatch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])

        _stopwatch.dataSource = self
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

    func resumeFeeding(_ feeding: Feeding) {
        _stopwatch.startFeeding(at: feeding.duration(), on: feeding.side)
        if feeding.isPaused {
            _stopwatch.pause()
        }
    }
}

extension NursingVC: FeedingStopwatchDataSource {
    public func currentFeedingDuration() -> TimeInterval? {
        return nil
    }
}
