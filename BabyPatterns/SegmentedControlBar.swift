//
//  SegmentedControlBar.swift
//  BabyPatterns
//
//  Created by Jason Zurita on 12/11/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

protocol SegmentedControlBarDelegate: class {
    func segmentedControlBar(bar: SegmentedControlBar, segmentWasTapped index: Int)
}

class SegmentedControlBar: UIStackView {

    weak var delegate: SegmentedControlBarDelegate?
    fileprivate var segments: [Segment] = []

    @IBOutlet var view: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeView()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        initializeView()
    }

    private func initializeView() {
        loadNib()
        view.frame = bounds
        addSubview(view)
        distribution = .fillEqually
    }

    func configureSegmentedBar(titles: [String], defaultSegmentIndex: Int) {
        for (index, title) in titles.enumerated() {
            let segment = Segment(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            segment.delegate = self
            segment.titleLabel.text = title
            segment.index = index
            segment.isActive = index == defaultSegmentIndex
            addArrangedSubview(segment)

            segments.append(segment)
        }
    }

    func goToIndex(index: Int) {
        resetSegments()
        segments[index].isActive = true
    }

    fileprivate func resetSegments() {
        segments.forEach { segment in
            segment.isActive = false
        }
    }
}

extension SegmentedControlBar: SegmentDelegate {
    func segmentTapped(segment: Segment) {
        resetSegments()

        segment.isActive = true
        delegate?.segmentedControlBar(bar: self, segmentWasTapped: segment.index)
    }
}
