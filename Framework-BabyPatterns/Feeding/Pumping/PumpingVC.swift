import Library
import UIKit

public protocol PumpingActionProtocol {
    func pumpingAmountChosen(_ amount: SupplyAmount)
}

public typealias PumpingController = PumpingActionProtocol & FeedingController

public final class PumpingVC: UIViewController {
    private let _stopwatch = FeedingStopwatchView(feedingType: .pumping)
    private let possibleSupplyAmounts = stride(from: 0, to: 1000, by: 10).map {
        SupplyAmount(value: $0)
    }
    private let _amountCallback: (SupplyAmount) -> Void

    @IBOutlet var bodyLabels: [UILabel]!
    @IBOutlet var amountPicker: UIPickerView! {
        didSet {
            amountPicker.dataSource = self
            amountPicker.delegate = self
        }
    }
    @IBOutlet var stopwatchContainerView: UIView! {
        didSet {
            stopwatchContainerView.addSubview(_stopwatch)
            _stopwatch.bindFrameToSuperviewBounds()
        }
    }

    @IBOutlet var saveButton: UIButton! {
        didSet { styleButtonRounded(.bpLightBlue)(saveButton) }
    }

    public init(controller: PumpingController) {
        _amountCallback = controller.pumpingAmountChosen

        super.init(nibName: "\(type(of: self))", bundle: Bundle(for: type(of: self)))

        _stopwatch.onStart = controller.start(feeding:side:)
        _stopwatch.onEnd = controller.end(feeding:side:)
        _stopwatch.onPause = controller.pause(feeeding:side:)
        _stopwatch.onResume = controller.resume(feeding:side:)
        _stopwatch.lastFeedingSide = controller.lastFeedingSide(type: .pumping)
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        bodyLabels.forEach { styleLabelP1($0) }
    }

    public func resume(feeding: Feeding) {
        _stopwatch.startFeeding(at: feeding.duration(), on: feeding.side)
        if feeding.isPaused {
            _stopwatch.pause()
        }
    }

    @IBAction func saveButtonPressed(_: UIButton) {
        let row = amountPicker.selectedRow(inComponent: 0)
        // TODO: alert user of failure from this guard
        guard row >= 0 else { return }
        _amountCallback(possibleSupplyAmounts[row])
    }
}

extension PumpingVC: UIPickerViewDataSource {
    public func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return possibleSupplyAmounts.count
    }
}

extension PumpingVC: UIPickerViewDelegate {
    public func pickerView(_: UIPickerView,
                           attributedTitleForRow row: Int,
                           forComponent _: Int) -> NSAttributedString? {
        let s = possibleSupplyAmounts[row].displayValue(for: .ounces)
        return NSAttributedString(string: s,
                                  attributes: [
                                      .font: UIFont.notoSansRegular(ofSize: 20),
                                      .foregroundColor: UIColor.black,
        ])
    }
}
