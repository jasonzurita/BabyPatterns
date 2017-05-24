//
//  CircleButton.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/14/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class CircleToggleButton: UIButton {

    @IBInspectable var normalColor: UIColor = UIColor.gray {
        didSet {
            backgroundColor = normalColor
        }
    }
    @IBInspectable var activeColor: UIColor = UIColor.blue
    @IBInspectable var normalText: String = "Left" {
        didSet {
            setTitle(normalText, for: .normal)
        }
    }

    @IBInspectable var isActive: Bool = false {
        didSet {
            updateButton()
        }
    }

    private var activeBorder: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    private func setupButton() {
        layer.cornerRadius = frame.width * 0.5
        backgroundColor = normalColor
        setTitle(normalText, for: .normal)
    }

    private func updateButton() {
        if isActive {
            backgroundColor = activeColor

            activeBorder = makeActiveBorder()
            insertSubview(activeBorder!, at: 0)
        } else {
            backgroundColor = normalColor

            setTitle(normalText, for: .normal)

            activeBorder?.removeFromSuperview()
            activeBorder = nil
        }
    }

    private func makeActiveBorder() -> UIView {
        let delta: CGFloat = 8
        let largerFrame = CGRect(x: -(delta * 0.5),
                                 y: -(delta * 0.5),
                                 width: frame.width + delta,
                                 height: frame.height + delta)

        let view = UIView(frame: largerFrame)
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = activeColor.cgColor
        view.layer.borderWidth = 2.0
        view.layer.cornerRadius = largerFrame.width * 0.5
        view.isUserInteractionEnabled = false

        return view
    }

}
