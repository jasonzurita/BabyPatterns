//
//  Feeding.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/16/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

struct Feeding {
    let type: FeedingType
    let side: FeedingSide
    let startDate: Date
    var serverKey: String?
    var endDate: Date?
    var lastPausedDate: Date?
    var pausedTime: TimeInterval
    let supplyAmount: Double

    let shouldPrintDebugString = true

    var isPaused: Bool {
        return lastPausedDate != nil
    }

    var isFinished: Bool {
        return endDate != nil
    }

    init(type: FeedingType,
         side: FeedingSide,
         startDate: Date,
         endDate: Date? = nil,
         lastPausedDate: Date? = nil,
         supplyAmount: Double = 0.0,
         pausedTime: TimeInterval = 0.0,
         serverKey: String? = nil) {

        self.type = type
        self.side = side
        self.startDate = startDate
        self.endDate = endDate
        self.lastPausedDate = lastPausedDate
        self.supplyAmount = supplyAmount
        self.pausedTime = pausedTime
        self.serverKey = serverKey
    }

    init?(json: [String: Any], serverKey: String) {
        guard let typeRawValue = json[K.JsonFields.FeedingType] as? String else { return nil }
        guard let type = FeedingType(rawValue: typeRawValue) else { return nil }
        guard let sideRawValue = json[K.JsonFields.Side] as? Int else { return nil }
        guard let side = FeedingSide(rawValue: sideRawValue) else { return nil }
        guard let startDate = Date(timeInterval: json[K.JsonFields.StartDate]) else { return nil }
        let endDate = Date(timeInterval: json[K.JsonFields.EndDate])

        let lastPausedDate = Date(timeInterval: json[K.JsonFields.LastPausedDate])

        guard let supplyAmount = json[K.JsonFields.SupplyAmount] as? Double else { return nil }
        guard let pausedTime = json[K.JsonFields.PausedTime] as? TimeInterval else { return nil }

        self.init(type: type,
                  side: side,
                  startDate: startDate,
                  endDate: endDate,
                  lastPausedDate: lastPausedDate,
                  supplyAmount: supplyAmount,
                  pausedTime: pausedTime,
                  serverKey: serverKey)
    }

    func eventJson() -> [String: Any] {
        let json: [String: Any] = [
            K.JsonFields.FeedingType: type.rawValue,
            K.JsonFields.Side: side.rawValue,
            K.JsonFields.StartDate: startDate.timeIntervalSince1970,
            K.JsonFields.PausedTime: pausedTime,
            K.JsonFields.EndDate: endDate?.timeIntervalSince1970 ?? 0.0,
            K.JsonFields.LastPausedDate: lastPausedDate?.timeIntervalSince1970 ?? 0.0,
            K.JsonFields.SupplyAmount: supplyAmount,
        ]

        return json
    }

    func duration() -> TimeInterval {
        return round(baseDuration() - fullPausedTime())
    }

    private func baseDuration() -> TimeInterval {
        if let endDate = endDate {
            return endDate.timeIntervalSince(startDate)
        } else {
            return abs(startDate.timeIntervalSinceNow)
        }
    }

    private func fullPausedTime() -> TimeInterval {
        var adjustment: TimeInterval = 0.0
        if let lastPausedDate = lastPausedDate {
            adjustment = abs(lastPausedDate.timeIntervalSinceNow)
        }

        return pausedTime + adjustment
    }
}
