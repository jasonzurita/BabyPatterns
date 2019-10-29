import Foundation

public struct K {
    // TODO: reconcile this duplication with `Constants.swift`
    public struct JsonFields {
        public static let FeedingType = "type"
        public static let Side = "side"
        public static let StartDate = "startDate"
        public static let EndDate = "endDate"
        public static let LastPausedDate = "lastPausedDate"
        public static let SupplyAmount = "supplyAmount"
        public static let PausedTime = "pausedTime"
    }
}

// TODO: reconcile this duplication
private extension Date {
    init?(timeInterval: Any?) {
        guard let i = timeInterval as? TimeInterval, i > 0 else { return nil }
        self = Date(timeIntervalSince1970: i)
    }
}

public struct Feeding: Codable {
    public let type: FeedingType
    public let side: FeedingSide
    public let startDate: Date
    public var serverKey: String?
    public var endDate: Date?
    // TODO: make sure we can't have a lastPausedTime after the endDate
    // i.e., the lastPauseDate should be limited
    public var lastPausedDate: Date?
    public var pausedTime: TimeInterval
    public let supplyAmount: SupplyAmount

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
                supplyAmount: SupplyAmount,
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

    // TODO: put under a test and make codable!
    public init?(json: [String: Any], serverKey: String) {
        guard let typeRawValue = json[K.JsonFields.FeedingType] as? String else { return nil }
        guard let type = FeedingType(rawValue: typeRawValue) else { return nil }
        guard let sideRawValue = json[K.JsonFields.Side] as? Int else { return nil }
        guard let side = FeedingSide(rawValue: sideRawValue) else { return nil }
        guard let startDate = Date(timeInterval: json[K.JsonFields.StartDate]) else { return nil }
        let endDate = Date(timeInterval: json[K.JsonFields.EndDate])

        let lastPausedDate = Date(timeInterval: json[K.JsonFields.LastPausedDate])

        guard let amount = json[K.JsonFields.SupplyAmount] as? Int else { return nil }
        let supplyAmount = SupplyAmount(value: amount)
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

    // TODO: put this under a test and then make use of codable!
    // (then find other cases like this and update them too)
    public func eventJson() -> [String: Any] {
        let json: [String: Any] = [
            K.JsonFields.FeedingType: type.rawValue,
            K.JsonFields.Side: side.rawValue,
            K.JsonFields.StartDate: startDate.timeIntervalSince1970,
            K.JsonFields.PausedTime: pausedTime,
            K.JsonFields.EndDate: endDate?.timeIntervalSince1970 ?? 0.0,
            K.JsonFields.LastPausedDate: lastPausedDate?.timeIntervalSince1970 ?? 0.0,
            K.JsonFields.SupplyAmount: supplyAmount.value,
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
            if let endDate = endDate {
                adjustment = abs(lastPausedDate.timeIntervalSince(endDate))
            } else {
                adjustment = abs(lastPausedDate.timeIntervalSinceNow)
            }
        }

        return pausedTime + adjustment
    }
}
