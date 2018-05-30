import Library
import UIKit

public protocol Event {
    var endDate: Date { get }
}

public final class HistoryVC: UIViewController, Loggable {
    private enum TimeWindow: TimeInterval {
        case day = 86_400 // in seconds
        case week = 604_800 // in seconds
        case month = 2_592_000 // in seconds
    }

    public let shouldPrintDebugLog = true
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    public override var description: String { return "\(type(of: self))" }

    private var screenTimeWindow: TimeWindow = .day {
        didSet {
            setupGraph()
        }
    }

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollContentView: UIView!

    let events: [Event]

    private let yOffset: CGFloat = 6
    private let barGraphElementWidth: CGFloat = 2
    private var notificationToken: NSObjectProtocol?

    private var pointsPerSecond: CGFloat {
        return scrollView.frame.width / CGFloat(screenTimeWindow.rawValue)
    }

    public init(events: [Event]) {
        self.events = events
        super.init(nibName: "\(type(of: self))", bundle: Bundle(for: type(of: self)))
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        modalTransitionStyle = .crossDissolve
        setupGraph()
    }

    private func setupGraph() {
        guard let lastEvent = events.last else {
            log("no events to show...", object: self, type: .warning)
            return
        }

        let graphWindow = DateInterval(start: lastEvent.endDate, end: Date())
        layoutFeedings(events, inWindow: graphWindow)
    }

    private func layoutFeedings(_ events: [Event], inWindow window: DateInterval) {
        scrollContentView.subviews.forEach { $0.removeFromSuperview() }
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        for event in events {
            let x = xFeedingLocation(forDate: event.endDate, inWindow: window)

            let graphElement = BarGraphLollipop()
            scrollContentView.addSubview(graphElement)

            graphElement.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                graphElement.heightAnchor.constraint(equalTo: scrollContentView.heightAnchor, multiplier: 0.5),
                graphElement.widthAnchor.constraint(equalToConstant: barGraphElementWidth),
                scrollContentView.bottomAnchor.constraint(equalTo: graphElement.bottomAnchor, constant: yOffset),
                graphElement.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor, constant: x),
                scrollContentView.trailingAnchor
                    .constraint(greaterThanOrEqualTo: graphElement.trailingAnchor, constant: 10),
            ])
        }
    }

    private func xFeedingLocation(forDate date: Date, inWindow window: DateInterval) -> CGFloat {
        // TODO: window.end.timeIntervalSinceNow should be something like the full window or from start to end, etc.
        let secondsSinceNow = CGFloat(abs(date.timeIntervalSince(window.end)))
        return pointsPerSecond * CGFloat(secondsSinceNow) + barGraphElementWidth
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        let center = NotificationCenter.default
        notificationToken = center.addObserver(forName: .UIDeviceOrientationDidChange,
                                               object: nil,
                                               queue: nil,
                                               using: { [weak self] _ in
                                                   if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
                                                       self?.dismiss(animated: true, completion: nil)

                                                       UIDevice.current.endGeneratingDeviceOrientationNotifications()
                                                       guard let token = self?.notificationToken else { return }
                                                       center.removeObserver(token)
                                                   }
        })
    }

    @IBAction func exitHistoryButtonPressed(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            screenTimeWindow = .day
        case 1:
            screenTimeWindow = .week
        case 2:
            screenTimeWindow = .month
        default:
            fatalError("Impossible segement selected...")
        }
    }
}
