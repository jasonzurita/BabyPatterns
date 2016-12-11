//
//  SegmentedControlBar.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/11/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

protocol SegmentedControlBarDelegate: class {
    func segmentedControlBar(bar:SegmentedControlBar, segmentWasTapped index:Int)
}

class SegmentedControlBar: UIStackView {

    //properties
    weak var delegate:SegmentedControlBarDelegate?
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
        distribution = .fillEqually;
    }
    
    func configureSegmentedBar(titles:[String], defaultSegmentIndex:Int, delegate:SegmentedControlBarDelegate) {
        self.delegate = delegate

        for (index, title) in titles.enumerated() {
            let segment = Segment(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            segment.titleLabel.text = title
            segment.index = index
            segment.delegate = self
            if index == defaultSegmentIndex {
                segment.isActive = true
            } else {
                segment.isActive = false
            }
            addArrangedSubview(segment)
        }
    }
}

extension SegmentedControlBar: SegmentDelegate {
    func segmentTapped(segment: Segment) {
        
        let segments = arrangedSubviews.flatMap { $0 as? Segment }.filter { $0 !== segment }
        resetSegments(segments:segments)
        
        delegate?.segmentedControlBar(bar: self, segmentWasTapped: segment.index)
    }
    
    private func resetSegments(segments:[Segment]) {
        for s in segments {
            s.isActive = false
        }
    }
}
