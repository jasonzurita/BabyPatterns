//
//  BarGraphLollipop.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 1/31/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

class BarGraphLollipop: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var circle: Circle!
    @IBOutlet weak var barView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBarGraph()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBarGraph()
    }

    private func setupBarGraph() {
        loadNib()
        view.frame = bounds
        addSubview(view)
        // barView.backgroundColor = UIColor.green
    }
}
