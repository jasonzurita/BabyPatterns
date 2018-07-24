import Library
import UIKit

public protocol Event {
    var endDate: Date { get }
    var type: FeedingType { get }
}

public protocol FeedingSummaryProtocol {
    var timeSinceLastNursing: TimeInterval { get }
    var lastNursingSide: FeedingSide { get }
    var averageNursingDuration: TimeInterval { get }
    var timeSinceLastPumping: TimeInterval { get }
    var lastPumpingSide: FeedingSide { get }
    var lastPumpedAmount: SupplyAmount { get }
    var timeSinceLastBottleFeeding: TimeInterval { get }
    var remainingSupplyAmount: SupplyAmount { get }
    var desiredSupplyAmount: SupplyAmount { get }
}

public final class HistoryVc: UIViewController, Loggable {
    private enum TimeWindow: TimeInterval {
        case twelveHours = 43_200 // in seconds
        case day = 86_400 // in seconds
        case week = 604_800 // in seconds
        case month = 2_592_000 // in seconds
    }

    public let shouldPrintDebugLog = true
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    public override var description: String { return "\(type(of: self))" }

    private var screenTimeWindow: TimeWindow = .twelveHours {
        didSet {
            updateAverageNursingLabel()
            setupGraph()
        }
    }

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollContentView: UIView!
    @IBOutlet var headingLabels: [UILabel]!

    @IBOutlet var nursingHeadingLabel: UILabel!
    @IBOutlet var pumpingHeadingLabel: UILabel!
    @IBOutlet var bottleHeadingLabel: UILabel!

    @IBOutlet var bodyLabels: [UILabel]!
    @IBOutlet var lastNursingLabel: UILabel! {
        didSet { lastNursingLabel.text = lastTimeText(_summary.timeSinceLastNursing) }
    }
    @IBOutlet var lastNursingSideLabel: UILabel! {
        didSet { lastNursingSideLabel.text = "  Last side: \(_summary.lastNursingSide)" }
    }
    @IBOutlet var averageNursingLabel: UILabel! {
        didSet { updateAverageNursingLabel() }
    }
    @IBOutlet var lastPumpingLabel: UILabel! {
        didSet { lastPumpingLabel.text = lastTimeText(_summary.timeSinceLastNursing) }
    }
    @IBOutlet var lastPumpingSideLabel: UILabel! {
        didSet { lastPumpingSideLabel.text = "  Last side: \(_summary.lastPumpingSide)" }
    }
    @IBOutlet var lastPumpedAmount: UILabel! {
        didSet {
            let lastAmount = _summary.lastPumpedAmount.displayText(for: .ounces)
            lastPumpedAmount.text = "  Last amount pumped: \(lastAmount)"
        }
    }
    @IBOutlet var lastBottleFeedingLabel: UILabel! {
        didSet { lastBottleFeedingLabel.text = lastTimeText(_summary.timeSinceLastBottleFeeding) }
    }
    @IBOutlet var remainingSupplyLabel: UILabel! {
        didSet {
            let remainingSupply = _summary.remainingSupplyAmount.displayText(for: .ounces)
            remainingSupplyLabel.text = "  Remaining supply: \(remainingSupply)"
        }
    }
    @IBOutlet var desiredSupplyLabel: UILabel! {
        didSet {
            let desiredSupply = _summary.desiredSupplyAmount.displayText(for: .ounces)
            desiredSupplyLabel.text = "  Desired supply: \(desiredSupply)"
        }
    }

    @IBOutlet var timeWindowSegmentedControl: UISegmentedControl! {
        didSet {
            timeWindowSegmentedControl.tintColor = .bpMediumBlue
            let font = UIFont.notoSansRegular(ofSize: 14)
            let attributes: [NSAttributedStringKey: Any] = [.font: font]
            timeWindowSegmentedControl.setTitleTextAttributes(attributes, for: .normal)
        }
    }

    private func lastTimeText(_ lastTime: TimeInterval) -> String {
        let hours = lastTime.stringFromSecondsToHours(zeroPadding: false)
        let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: false)
        return "  Last time: \(hours.string)h \(minutes.string)m ago"
    }

    private let events: [Event]
    private let _summary: FeedingSummaryProtocol

    private let yOffset: CGFloat = 6
    private let barGraphElementWidth: CGFloat = 4
    private var notificationToken: NSObjectProtocol?

    private var pointsPerSecond: CGFloat {
        return scrollView.frame.width / CGFloat(screenTimeWindow.rawValue)
    }

    public init(events: [Event], summary: FeedingSummaryProtocol) {
        self.events = events
        _summary = summary
        super.init(nibName: "\(type(of: self))", bundle: Bundle.framework)
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupGraph()
        completeStyling()

        addColorIndicator(labelView: nursingHeadingLabel, color: .bpPink)
        addColorIndicator(labelView: pumpingHeadingLabel, color: .bpGreen)
        addColorIndicator(labelView: bottleHeadingLabel, color: .bpMediumBlue)
    }

    private func addColorIndicator(labelView: UIView, color: UIColor) {
        let colorIndicator = UIView()
        colorIndicator.translatesAutoresizingMaskIntoConstraints = false
        colorIndicator.backgroundColor = color
        labelView.addSubview(colorIndicator)

        let heightMultiplier: CGFloat = 0.4
        NSLayoutConstraint.activate([
            colorIndicator.heightAnchor.constraint(equalTo: labelView.heightAnchor, multiplier: heightMultiplier),
            colorIndicator.widthAnchor.constraint(equalTo: colorIndicator.heightAnchor),
            colorIndicator.centerYAnchor.constraint(equalTo: labelView.centerYAnchor),
            colorIndicator.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: 5),
        ])

        let size = labelView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        colorIndicator.layer.cornerRadius = size.height * heightMultiplier * 0.5
    }

    private func completeStyling() {
        headingLabels.forEach { styleLabelH2($0) }
        bodyLabels.forEach { styleLabelP2($0) }
    }

    private func updateAverageNursingLabel() {
        // TODO: make sure this makes sense
        // also the value needs to change depending on the window change
        let window: String
        switch screenTimeWindow {
        case .twelveHours:
            window = "12h"
        case .day:
            window = "day"
        case .week:
            window = "week"
        case .month:
            window = "month"
        }
        averageNursingLabel.text = "  Average feeding (\(window)) \(_summary.averageNursingDuration) m"
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

            let graphElement = UIView()
            switch event.type {
            case .pumping:
                styleBarGraphElementPumping(graphElement)
            case .nursing:
                styleBarGraphElementNursing(graphElement)
            case .bottle:
                styleBarGraphElementBottle(graphElement)
            case .none:
                log("Event has feeding type of none: \(event)", object: self, type: .error)
            }
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

    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            screenTimeWindow = .twelveHours
        case 1:
            screenTimeWindow = .day
        case 2:
            screenTimeWindow = .week
        case 3:
            screenTimeWindow = .month
        default:
            fatalError("Impossible segement selected...")
        }
    }
}
