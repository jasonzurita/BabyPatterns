import Common
import Library
import UIKit

public protocol BottleDelegate: class {
    func logBottleFeeding(withAmount amount: Int, time: Date)
}

public protocol BottleDataSource: class {
    func remainingSupply() -> SupplyAmount
    func desiredMaxSupply() -> SupplyAmount
}

public final class BottleVC: UIViewController, Loggable {
    public let shouldPrintDebugLog = true

    public weak var delegate: BottleDelegate?
    public weak var dataSource: BottleDataSource?

    @IBOutlet var bodyLabels: [UILabel]!
    @IBOutlet var unitLabels: [UILabel]!
    @IBOutlet var saveButton: UIButton! {
        didSet { styleButtonRounded(.bpLightBlue)(saveButton) }
    }

    @IBOutlet var remainingSupplyLabel: UILabel! {
        didSet {
            let style = styleLabelFont(.notoSansRegular(ofSize: 38))
            style(remainingSupplyLabel) }
    }

    @IBOutlet var amountFedLabel: UILabel! {
        didSet {
            let style = styleLabelFont(.notoSansRegular(ofSize: 38))
            style(amountFedLabel) }
    }

    @IBOutlet var sliderContainerView: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var slider: UISlider!

    @IBOutlet var bottleBottomFill: UIImageView!
    @IBOutlet var bottleBaseView: UIImageView!
    @IBOutlet var bottleFillHeightConstraint: NSLayoutConstraint!

    @IBOutlet var remainingSupplyLineYConstraint: NSLayoutConstraint!
    @IBOutlet var remainingSupplyLineView: UIView!

    private var _maxSupplyHeight: Float {
        return Float(bottleBaseView.frame.height +
            CGFloat(K.Defaults.BottleFillOverlapWithBottomFillImage) -
            bottleBottomFill.frame.height -
            CGFloat(K.Defaults.BottleTopHeight))
    }

    private var _remainingSupplyHeight: Float {
        // TODO: think if returning 1.0 is the best thing to do
        guard let ds = dataSource else { return 1.0 }
        let maxSupply = ds.desiredMaxSupply().value
        let remainingSupply = ds.remainingSupply().value
        return (_maxSupplyHeight / Float(maxSupply)) * Float(remainingSupply)
    }

    public init() {
        super.init(nibName: "\(type(of: self))", bundle: Bundle(for: type(of: self)))
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        slider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 0.5)
        slider.minimumValue = 0
        configureRemainingStyles()
    }

    private func configureRemainingStyles() {
        bodyLabels.forEach { styleLabelH2($0) }
        unitLabels.forEach { styleLabelP1($0) }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabels()
    }

    private func updateLabels() {
        guard let ds = dataSource else { return }
        remainingSupplyLabel.text = ds.remainingSupply().displayValue(for: .ounces)
        amountFedLabel.text = "0.0"
    }

    // TODO: the use of the bool below is hacky and should be revisted for a real solution
    private var _hasConfiguredView = false
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _hasConfiguredView = false
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !_hasConfiguredView else { return }
        _hasConfiguredView = true
        configureSlider()
        configureBottleFillHeight()
        configureRemainingSupplyLine()
    }

    private func configureSlider() {
        slider.maximumValue = _maxSupplyHeight
        slider.value = _remainingSupplyHeight
    }

    private func configureBottleFillHeight() {
        bottleFillHeightConstraint.constant = CGFloat(_remainingSupplyHeight)
    }

    private func configureRemainingSupplyLine() {
        remainingSupplyLineYConstraint.constant =
            -(CGFloat(_remainingSupplyHeight) -
                CGFloat(K.Defaults.BottleFillOverlapWithBottomFillImage) +
                bottleBottomFill.frame.height)
    }

    @IBAction func saveButtonPressed(_: UIButton) {
        guard let ds = dataSource else { return }
        let remainingSupply = ds.remainingSupply().value
        let consumedAmount = convert(sliderValue: slider.value,
                                     withRemainingSupply: Float(remainingSupply),
                                     remainingSupplyHeight: Float(_remainingSupplyHeight))
        delegate?.logBottleFeeding(withAmount: Int(consumedAmount), time: datePicker.date)
        updateLabels()
        configureRemainingSupplyLine()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let ds = dataSource else { return }

        sender.value = sender.value > _remainingSupplyHeight ? _remainingSupplyHeight : sender.value
        bottleFillHeightConstraint.constant = CGFloat(sender.value)

        let remainingSupply = ds.remainingSupply().value
        let amount = convert(sliderValue: slider.value,
                             withRemainingSupply: Float(remainingSupply),
                             remainingSupplyHeight: Float(_remainingSupplyHeight))
        let amountFed = SupplyAmount(value: Int(amount))
        amountFedLabel.text = amountFed.displayValue(for: .ounces)
    }

    private func convert(sliderValue: Float,
                         withRemainingSupply remainingSupply: Float,
                         remainingSupplyHeight height: Float) -> Float {
        guard height > 0 else {
            return remainingSupply
        }
        let amount = remainingSupply - remainingSupply / height * sliderValue
        let oneDecimalPlaceAmount = Float(Int(amount * 0.1)) * 10
        return oneDecimalPlaceAmount
    }
}

extension BottleVC: UIPickerViewDelegate {
    public func pickerView(_: UIPickerView, didSelectRow _: Int, inComponent _: Int) {
        log("Row selected", object: self, type: .info)
    }

    public func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return "\(row)"
    }
}
