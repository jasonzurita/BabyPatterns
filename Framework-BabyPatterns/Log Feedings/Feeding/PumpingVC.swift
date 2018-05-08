import UIKit

public final class PumpingVC: UIViewController {

    private let _stopwatch = FeedingStopwatchView(feedingType: .pumping)

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
    }

    public func resume(feeding: Feeding) {
        _stopwatch.startFeeding(at: feeding.duration(), on: feeding.side)
        if feeding.isPaused {
            _stopwatch.pause()
        }
    }
}
