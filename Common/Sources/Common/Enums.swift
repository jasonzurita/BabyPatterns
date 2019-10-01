public enum FeedingType: String, Codable {
    case nursing = "Nursing"
    case pumping = "Pumping"
    case bottle = "Bottle"
    case none = "None"

    public static let allValues = [nursing, pumping, bottle]
}

public enum FeedingAction: Int, Codable {
    case start, stop, pause
}

// TODO: decide on the below enums
public enum FirebaseRequestType: String {
    case feedings
    case profile
    case profilePhoto
}

public enum FeedingSide: Int, Codable {
    case left = 1
    case right
    case none

    public func asText() -> String {
        switch self {
        case .left:
            return "Left"
        case .right:
            return "Right"
        case .none:
            return ""
        }
    }
}

public enum NursingEventJsonError: Error {
    case invalidNursingEvent
}
