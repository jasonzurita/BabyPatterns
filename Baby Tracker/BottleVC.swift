//
//  BottleVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/11/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class BottleVC: UIViewController {
    
    fileprivate let shouldPrintDebugString = true
    
    private let _feedingType:FeedingType = .bottle
    
    var delegate:BottleFeedingDelegate?
    var dataSource:FeedingsDataSource?
    
    @IBOutlet weak var remainingSupplyLabel: UILabel!
    @IBOutlet weak var amountFedLabel: UILabel!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSlider()
        
        guard let ds = dataSource else { return }
        remainingSupplyLabel.text = "\(ds.remainingSupply())"
    }
    
    private func configureSlider() {
        slider.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 0.5)
        slider.minimumValue = 0
        slider.maximumValue = Float(dataSource?.remainingSupply() ?? 1.0)
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        delegate?.logBottleFeeding(withAmount: Double(slider.value), time: datePicker.date)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("Slider value: \(sender.value)")
    }
}

extension BottleVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Logger.log(message: "Row selected", object: self, type: .info, shouldPrintDebugLog: shouldPrintDebugString)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
}
