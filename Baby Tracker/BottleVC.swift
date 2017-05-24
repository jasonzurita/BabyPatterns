//
//  BottleVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/11/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class BottleVC: UIViewController, Loggable {

    let shouldPrintDebugLog = true

    private let _feedingType: FeedingType = .bottle

    weak var delegate: BottleFeedingDelegate?
    weak var dataSource: FeedingsDataSource?

    @IBOutlet weak var remainingSupplyLabel: UILabel!
    @IBOutlet weak var amountFedLabel: UILabel!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var slider: UISlider!

    @IBOutlet weak var bottleBottomFill: UIImageView!
    @IBOutlet weak var bottleBaseView: UIImageView!
    @IBOutlet weak var bottleFillHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var remainingSupplyLineYConstraint: NSLayoutConstraint!
    @IBOutlet weak var remainingSupplyLineView: UIView!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSlider()
        configureBottle()
        configureRemainingSupplyLine()
        configureLabels()
    }

    private func configureSlider() {
        slider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 0.5)
        slider.minimumValue = 0
        slider.maximumValue = _maxSupplyHeight
        slider.value = _remainingSupplyHeight
    }

    private func configureBottle() {
        bottleFillHeightConstraint.constant = CGFloat(_remainingSupplyHeight)
    }

    private func configureRemainingSupplyLine() {
        remainingSupplyLineYConstraint.constant += CGFloat(_maxSupplyHeight - _remainingSupplyHeight)
    }

    private func configureLabels() {
        guard let ds = dataSource else { return }
        remainingSupplyLabel.text = String.localizedStringWithFormat("%.1f%", ds.remainingSupply())
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        delegate?.logBottleFeeding(withAmount: Double(slider.value), time: datePicker.date)
        configureLabels()
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        guard let ds = dataSource else { return }

        sender.value = sender.value > _remainingSupplyHeight ? _remainingSupplyHeight : sender.value
        bottleFillHeightConstraint.constant = CGFloat(sender.value)

        //TODO: break this out into a few variables with good names to help readability
        let amountFed = Float(ds.remainingSupply()) -
                        (Float(ds.remainingSupply()) / _remainingSupplyHeight) *
                        slider.value

        amountFedLabel.text = String.localizedStringWithFormat("%.1f%", CGFloat(amountFed))
    }
}

extension BottleVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log("Row selected", object: self, type: .info)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
}
