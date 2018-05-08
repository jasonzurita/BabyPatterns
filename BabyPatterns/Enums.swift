public enum FeedingType: String {
    case nursing = "Nursing"
    case pumping = "Pumping"
    case bottle = "Bottle"
    case none = "None"

    public static let allValues = [nursing, pumping, bottle]
}

public enum FirebaseRequestType: String {
    case feedings
    case profile
    case profilePhoto
}

public enum FeedingSide: Int {
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
