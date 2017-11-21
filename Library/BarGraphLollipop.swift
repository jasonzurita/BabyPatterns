//
//  BarGraphLollipop.swift
//  BabyPatterns
//
//  Created by Jason Zurita on 1/31/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import UIKit

public final class BarGraphLollipop: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var circle: Circle!
    @IBOutlet weak var barView: UIView!

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupBarGraph()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBarGraph()
    }

    private func setupBarGraph() {
        loadNib()
        view.frame = bounds
        addSubview(view)
    }
}
