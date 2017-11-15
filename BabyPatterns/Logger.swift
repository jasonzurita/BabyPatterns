//
//  Logger.swift
//  BabyPatterns
//
//  Created by Jason Zurita on 3/13/17.
//  Copyright © 2017 Jason Zurita. All rights reserved.
//

import Foundation

protocol Loggable {
    var shouldPrintDebugLog: Bool { get }
    func log(_ message: String, object: Any, type: LogType)
}

extension Loggable {
    private var _shouldPrintDebugLog: Bool { return true }

    func log(_ message: String, object: Any, type: LogType) {
        if _shouldPrintDebugLog && shouldPrintDebugLog {
            print("\(type.rawValue) -> \(Swift.type(of: object)): " + message)
        }
    }
}
