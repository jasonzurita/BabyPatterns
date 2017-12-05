//
//  Feeding.swift
//  BabyPatterns
//
//  Created by Jason Zurita on 12/16/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import Foundation

public struct Feeding {
    public let type: FeedingType
    public let side: FeedingSide
    public let startDate: Date
    public var serverKey: String?
    public var endDate: Date?
    public var lastPausedDate: Date?
    public var pausedTime: TimeInterval
    public let supplyAmount: Double

    public let shouldPrintDebugString = true

    public var isPaused: Bool {
        return lastPausedDate != nil
    }

    public var isFinished: Bool {
        return endDate != nil
    }

    public init(type: FeedingType,
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

    public init?(json: [String: Any], serverKey: String) {
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

    public func eventJson() -> [String: Any] {
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

    public func duration() -> TimeInterval {
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
