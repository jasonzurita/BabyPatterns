//
//  Tile.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 11/9/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

enum TileType {
    case feeding = "Feeding",
    case diaper = "Changing"
}


class Tile: UIButton {

    let shouldPrintDebugString = true //set to false to silence this class
    
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
