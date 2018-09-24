import Library
import UIKit

public protocol Event {
    var endDate: Date { get }
    var type: FeedingType { get }
    var duration: TimeInterval { get }
    var supplyAmount: SupplyAmount { get }
}

// func averageNursingDuration(filterWindow _: DateInterval) -> TimeInterval {
public protocol FeedingSummaryProtocol {
    var timeSinceLastNursing: TimeInterval { get }
    var lastNursingSide: FeedingSide { get }
    var averageNursingDuration: (DateInterval) -> TimeInterval { get }
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

    private var _previouslySelectedFeedingAction: (() -> Void)?

    public override var description: String { return "\(type(of: self))" }

    private var screenTimeWindow: TimeWindow = .twelveHours {
        didSet {
            updateAverageNursingLabel()
            setupGraph()
        }
    }

    @IBOutlet var graphHistoryLabel: UILabel! {
        didSet {
            graphHistoryLabel.text = "History"
            styleLabelH2(graphHistoryLabel)
        }
    }

    @IBOutlet var graphBackgroundView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var scrollContentView: UIView! {
        didSet { scrollContentView.translatesAutoresizingMaskIntoConstraints = false }
    }
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
            let attributes: [NSAttributedString.Key: Any] = [.font: font]
            timeWindowSegmentedControl.setTitleTextAttributes(attributes, for: .normal)
        }
    }

    private func lastTimeText(_ lastTime: TimeInterval) -> String {
        let hours = lastTime.stringFromSecondsToHours(zeroPadding: false)
        let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: false)
        return "  Last: \(hours.string)h \(minutes.string)m ago"
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

        let now = Date()
        let start = Date(timeInterval: -screenTimeWindow.rawValue, since: now)
        let timeWindow = DateInterval(start: start, end: Date())
        let average = _summary.averageNursingDuration(timeWindow)
        // TODO: put in analytic event here to determine if hours is useful
        let hours = average.stringFromSecondsToHours(zeroPadding: false)
        let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: false)
        averageNursingLabel.text = "  Average feeding (last \(window)) \(hours.string)h \(minutes.string)m"
    }

    private let events: [Event]
    private let _summary: FeedingSummaryProtocol

    private let barGraphElementWidth: CGFloat = 4

    public init(events: [Event], summary: FeedingSummaryProtocol) {
        self.events = events
        _summary = summary
        super.init(nibName: "\(type(of: self))", bundle: Bundle.framework)
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true

        completeStyling()

        addColorIndicator(labelView: nursingHeadingLabel, color: .bpPink)
        addColorIndicator(labelView: pumpingHeadingLabel, color: .bpGreen)
        addColorIndicator(labelView: bottleHeadingLabel, color: .bpMediumBlue)
    }

    private func completeStyling() {
        headingLabels.forEach { styleLabelH2($0) }
        bodyLabels.forEach { styleLabelP2($0) }
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

        let size = labelView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        colorIndicator.layer.cornerRadius = size.height * heightMultiplier * 0.5
    }

    // Note: the styling needs to be completed like this because the frame
    // sizes need to be finalized
    private var _shouldCompleteStyling = true
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard _shouldCompleteStyling else { return }
        _shouldCompleteStyling = false

        setupGraph()

        let gradient = CAGradientLayer()
        gradient.frame = graphBackgroundView.bounds
        gradient.colors = [UIColor.bpLightGray.cgColor, UIColor.bpWhite.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 0.0)

        graphBackgroundView.layer.insertSublayer(gradient, at: 0)
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

// MARK: Graph drawing

extension HistoryVc {
    private var pointsPerSecond: CGFloat {
        // this assumes the scrollView's width is equal to the view's width
        // TODO: get rid of the UIScreen dependency
        return UIScreen.main.bounds.width / CGFloat(screenTimeWindow.rawValue)
    }

    // TODO: pull out the screen scale dependency
    private func setupGraph(for screenScale: CGFloat = UIScreen.main.scale) {
        guard let lastEvent = events.last else {
            // TODO: what do we show in this case?
            log("no events to show...", object: self, type: .warning)
            return
        }

        // TODO: should these go in their respective functions?
        scrollContentView.subviews.forEach { $0.removeFromSuperview() }
        scrollContentView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let graphWindow = DateInterval(start: lastEvent.endDate, end: Date())
        layoutFeedings(events, inWindow: graphWindow)

        // TODO: see if we can move this before the event check
        layoutXAxis(for: graphWindow, screenScale: screenScale)
    }

    private func layoutFeedings(_ events: [Event], inWindow window: DateInterval) {
        for event in events {
            let x = xFeedingLocation(forDate: event.endDate, inWindow: window)

            let graphElement = TapableView()
            graphElement.onTap = { [unowned self] element in
                self.selected(graphElement: element, event: event)
            }
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
                scrollContentView.bottomAnchor.constraint(equalTo: graphElement.bottomAnchor),
                graphElement.leftAnchor.constraint(equalTo: scrollContentView.leftAnchor, constant: x),
                scrollContentView.trailingAnchor
                    .constraint(greaterThanOrEqualTo: graphElement.trailingAnchor, constant: 10),
            ])
        }
    }

    private func selected(graphElement: UIView, event: Event) {
        _previouslySelectedFeedingAction?()
        let label = UILabel()
        label.textAlignment = .center

        let df = DateFormatter()
        df.dateFormat = "hh:mm a, MM/dd"

        let hours = event.duration.stringFromSecondsToHours(zeroPadding: false)
        let minutes = hours.remainder.stringFromSecondsToMinutes(zeroPadding: false)

        let detailLabelTextOptions: [([FeedingType], String)] = [
            ([.nursing, .pumping, .bottle], df.string(from: event.endDate)),
            ([.nursing, .pumping], "\(hours.string)h \(minutes.string)m long"),
            ([.pumping, .bottle], "\(event.supplyAmount.displayText(for: .ounces))"),
        ]

        label.text = detailLabelTextOptions
            .filter { $0.0.contains(event.type) }
            .map { $0.1 }
            .joined(separator: "\n")

        scrollContentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: graphElement.topAnchor, constant: -6),
            label.centerXAnchor.constraint(equalTo: graphElement.centerXAnchor),
        ])

        styleLabelP3(label)

        _previouslySelectedFeedingAction = { label.removeFromSuperview() }
    }

    private func xFeedingLocation(forDate date: Date, inWindow window: DateInterval) -> CGFloat {
        // TODO: window.end.timeIntervalSinceNow should be something like the full window or from start to end, etc.
        let secondsSinceNow = CGFloat(abs(date.timeIntervalSince(window.end)))

        // the first graph element will have spacing of `barGraphElementWidth` from left
        // margin because of the below addition AND the `leftAnchor` constraint above
        return pointsPerSecond * CGFloat(secondsSinceNow) + barGraphElementWidth
    }

    private func layoutXAxis(for window: DateInterval, screenScale: CGFloat) {
        let frequency: TimeInterval
        let divisor: TimeInterval
        let timeUnit: String
        switch screenTimeWindow {
        case .twelveHours:
            frequency = 3 * 60 * 60
            divisor = 3600
            timeUnit = "h"
        case .day:
            frequency = 6 * 60 * 60
            divisor = 3600
            timeUnit = "h"
        case .week:
            frequency = 24 * 60 * 60
            divisor = frequency
            timeUnit = "d"
        case .month:
            frequency = 7 * 24 * 60 * 60
            divisor = frequency
            timeUnit = "w"
        }

        let labelTimestamps = stride(from: abs(window.end.timeIntervalSinceNow),
                                     to: abs(window.start.timeIntervalSinceNow),
                                     by: frequency)

        let titles = ["now"] + stride(from: abs(window.end.timeIntervalSinceNow),
                                      to: abs(window.start.timeIntervalSinceNow),
                                      by: frequency).map { "\(Int($0 / divisor))\(timeUnit)" }.dropFirst()

        let attributes = [
            NSAttributedString.Key.font: UIFont.notoSansBold(ofSize: 14),
            NSAttributedString.Key.foregroundColor: UIColor.bpMediumGray,
        ]

        let y = scrollView.frame.height

        for viewData in zip(labelTimestamps, titles) {
            let textLayer = CATextLayer()
            textLayer.string = NSAttributedString(string: "\(viewData.1)", attributes: attributes)
            textLayer.contentsScale = screenScale
            let preferedSize = textLayer.preferredFrameSize()
            scrollContentView.layer.addSublayer(textLayer)

            let x = xFeedingLocation(forDate: Date(timeIntervalSinceNow: viewData.0), inWindow: window)
            textLayer.frame = CGRect(x: x, y: y, width: preferedSize.width, height: preferedSize.height)
        }
    }
}
