//
//  RoundedCornerButton.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/21/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornerButton: UIButton {

    @IBInspectable var titleText:String? {
        didSet {
            setTitle(titleText, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    private func setupButton() {
        layer.cornerRadius = frame.height * 0.5

    }
}
