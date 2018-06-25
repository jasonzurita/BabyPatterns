import Library
import UIKit

public protocol BottleDelegate: class {
    func logBottleFeeding(withAmount amount: Double, time: Date)
}

public protocol BottleDataSource: class {
    func remainingSupply() -> Double
    func desiredMaxSupply() -> Double
}

public final class BottleVC: UIViewController, Loggable {
    public let shouldPrintDebugLog = true

    public weak var delegate: BottleDelegate?
    public weak var dataSource: BottleDataSource?

    @IBOutlet var bodyLabels: [UILabel]!
    @IBOutlet var unitLabels: [UILabel]!
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
        guard let ds = dataSource else { return 1.0 }
        return (_maxSupplyHeight / Float(ds.desiredMaxSupply())) * Float(ds.remainingSupply())
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
        bodyLabels.forEach { styleH2Label($0) }
        unitLabels.forEach { styleBodyLabel($0) }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLabels()
    }

    private func updateLabels() {
        guard let ds = dataSource else { return }
        remainingSupplyLabel.text = String.localizedStringWithFormat("%.1f%", abs(ds.remainingSupply()))
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
        let consumedAmount = convert(sliderValue: slider.value,
                                     withRemainingSupply: Float(ds.remainingSupply()),
                                     remainingSupplyHeight: Float(_remainingSupplyHeight))
        delegate?.logBottleFeeding(withAmount: Double(consumedAmount), time: datePicker.date)
        updateLabels()
        configureRemainingSupplyLine()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let ds = dataSource else { return }

        sender.value = sender.value > _remainingSupplyHeight ? _remainingSupplyHeight : sender.value
        bottleFillHeightConstraint.constant = CGFloat(sender.value)

        let amountFed = convert(sliderValue: slider.value,
                                withRemainingSupply: Float(ds.remainingSupply()),
                                remainingSupplyHeight: Float(_remainingSupplyHeight))
        amountFedLabel.text = String.localizedStringWithFormat("%.1f%", abs(CGFloat(amountFed)))
    }

    private func convert(sliderValue: Float,
                         withRemainingSupply reminingSupply: Float,
                         remainingSupplyHeight height: Float) -> Float {
        let adjustedHeight = height > 0 ? height : 0.0001
        return reminingSupply - reminingSupply / adjustedHeight * sliderValue
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
