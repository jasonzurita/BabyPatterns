//
//  Segment.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/11/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

protocol SegmentDelegate: class {
    func segmentTapped(segment: Segment)
}

class Segment: UIView {

    weak var delegate: SegmentDelegate?

    var index = -1
    var isActive = false {
        didSet {
            selectedStatusBar.isHidden = !isActive
        }
    }

    @IBOutlet var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedStatusBar: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        view.frame = bounds
        addSubview(view)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesEnded(_: Set<UITouch>, with _: UIEvent?) {
        delegate?.segmentTapped(segment: self)
    }
}
