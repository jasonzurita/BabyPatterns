import UIKit
import Library

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
    @IBAction func addButtonPressed(_ sender: UIButton) {
        _amountCallback(10)
    }
}

extension PumpingVC: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return _amounts.count
    }
}

extension PumpingVC: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return _amounts[row]
    }
}
