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

protocol TileDelegate : class {
    func userDidTapTile(tile:Tile)
}


class Tile: UIView {

    //constants
    private let shouldPrintDebugString = true //set to false to silence this class
    
    weak var delegate:TileDelegate?

    //outlets
    @IBOutlet var view: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("Tile", owner: self, options: nil)
        view.frame = bounds
        addSubview(view)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {

        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
