//
//  Logger.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 3/13/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import Foundation

class Logger {

    private static let _shouldPrintDebugLog = true
    
    static func log(message:String, object:Any, type:LogType, shouldPrintDebugLog:Bool) {
        if _shouldPrintDebugLog && shouldPrintDebugLog {
            print("\(type.rawValue) -> \(type(of:object)): message")
        }
    }
}
