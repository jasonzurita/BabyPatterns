//
//  Tile.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/9/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

enum TileType {
    case feeding
    case changings
    
    static let allValues = [feeding, changings]
}

class Tile: UIView {

    //constants
    private let shouldPrintDebugString = true //set to false to silence this class
    
    var didTapCallback: (() -> Void)?
    
    @IBInspectable var title:String {
        set {
            titleLabel.text = newValue
        }
        
        get {
            return titleLabel.text ?? ""
        }
    }

    //outlets
    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed(String(describing: type(of:self)), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed(String(describing: type(of:self)), owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        didTapCallback?()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            printDebugString(string: "Touch pressure: \(touch.force/touch.maximumPossibleForce)")
        }
    }

    private func printDebugString(string:String) {
        if shouldPrintDebugString {
            print("\(type(of:self)): " + string)
        }
    }
}
