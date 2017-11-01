//
//  Toast.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/16/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class Toast: UILabel {

    var title = "toast label"

    convenience init(frame: CGRect, text: String) {
        self.init(frame:frame)
        title = text
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupToast()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupToast()
    }

    private func setupToast() {
        textAlignment = .center
        textColor = UIColor.white
        font = UIFont(name: "Helvetica", size: 32)

        layer.cornerRadius = frame.width * 0.1
        layer.masksToBounds = true

        backgroundColor = UIColor.gray
        alpha = 0.0
    }

    func presentInView(view: UIView) {
        text = title

        view.addSubview(self)
        UIView.animateKeyframes(withDuration: 2.4, delay: 0.0, options: .calculationModeLinear, animations: {

            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.05, animations: {
                self.alpha = 1.0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.05, relativeDuration: 0.15, animations: {
                self.alpha = 1.0
            })
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.8, animations: {
                self.alpha = 0.0
            })
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

}
