import Library
import UIKit

public protocol PumpingDelegate {
    func pumpingAmountChosen(_ amount: Double)
}

public typealias PumpingController = PumpingDelegate & FeedingController

public final class PumpingVC: UIViewController {
    private let _stopwatch = FeedingStopwatchView(feedingType: .pumping)
    private let _amounts = stride(from: 0, to: 10, by: 0.1).map { String($0) }
    private let _amountCallback: (Double) -> Void

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

    public init(controller: PumpingController) {
        _amountCallback = controller.pumpingAmountChosen

        super.init(nibName: "\(type(of: self))", bundle: Bundle(for: type(of: self)))

        _stopwatch.onStart = controller.start(feeding:side:)
        _stopwatch.onEnd = controller.end(feeding:side:)
        _stopwatch.onPause = controller.pause(feeeding:side:)
        _stopwatch.onResume = controller.resume(feeding:side:)
    }

    public required init?(coder _: NSCoder) { fatalError("\(#function) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func resume(feeding: Feeding) {
        _stopwatch.startFeeding(at: feeding.duration(), on: feeding.side)
        if feeding.isPaused {
            _stopwatch.pause()
        }
    }

    @IBAction func saveButtonPressed(_: UIButton) {
        let row = amountPicker.selectedRow(inComponent: 0)
        // TOOD: alert user of failure from this guard
        guard row >= 0, let amount = Double(_amounts[row]) else { return }
        _amountCallback(amount)
    }
}

extension PumpingVC: UIPickerViewDataSource {
    public func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return _amounts.count
    }
}

extension PumpingVC: UIPickerViewDelegate {
    public func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return _amounts[row]
    }
}
