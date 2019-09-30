import Swift

public struct WatchCommunication: Codable {
    public let feedingType: FeedingType
    public let feedingSide: FeedingSide
    public let action: FeedingAction

    public init(type: FeedingType, side: FeedingSide, action: FeedingAction) {
        feedingType = type
        feedingSide = side
        self.action = action
    }
}
