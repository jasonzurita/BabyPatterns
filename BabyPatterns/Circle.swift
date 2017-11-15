//
//  Circle.swift
//  BabyPatterns
//
//  Created by Jason Zurita on 1/31/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

class Circle: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCircle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCircle()
    }

    private func setupCircle() {
        //        layer.cornerRadius = frame.width * 0.5
        layer.backgroundColor = UIColor.blue.cgColor
    }
}
