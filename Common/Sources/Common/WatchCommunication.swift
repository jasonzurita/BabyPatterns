import Foundation

public struct WatchFeedingCommunication: Codable {
    public let feedingType: FeedingType
    public let feedingSide: FeedingSide
    public let action: FeedingAction

    public init(type: FeedingType, side: FeedingSide, action: FeedingAction) {
        feedingType = type
        feedingSide = side
        self.action = action
    }
}

public struct WatchContextCommunication: Codable {
    let requestedOn: Date
    public init(requestedOn: Date = Date()) {
        self.requestedOn = requestedOn
    }
}
