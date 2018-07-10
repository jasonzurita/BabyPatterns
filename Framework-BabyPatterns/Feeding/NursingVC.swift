import UIKit

public protocol FeedingController {
    func start(feeding type: FeedingType, side: FeedingSide)
    func end(feeding type: FeedingType, side: FeedingSide)
    func pause(feeeding type: FeedingType, side: FeedingSide)
    func resume(feeding type: FeedingType, side: FeedingSide)
    func lastFeedingSide(type: FeedingType) -> FeedingSide
}

// TODO: consider combining this vc and the feedingStopwatchView
public final class NursingVC: UIViewController {
    private let _stopwatch = FeedingStopwatchView(feedingType: .nursing)

    public init(controller: FeedingController) {
        super.init(nibName: nil, bundle: nil)
        _stopwatch.onStart = controller.start(feeding:side:)
        _stopwatch.onEnd = controller.end(feeding:side:)
        _stopwatch.onPause = controller.pause(feeeding:side:)
        _stopwatch.onResume = controller.resume(feeding:side:)
        _stopwatch.lastFeedingSide = controller.lastFeedingSide(type: .nursing)
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
    }

    public func resume(feeding: Feeding) {
        _stopwatch.startFeeding(at: feeding.duration(), on: feeding.side)
        if feeding.isPaused {
            _stopwatch.pause()
        }
    }
}
