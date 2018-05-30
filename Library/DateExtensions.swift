import Foundation

public extension Date {
    init?(timeInterval: Any?) {
        guard let i = timeInterval as? TimeInterval, i > 0 else { return nil }
        self = Date(timeIntervalSince1970: i)
    }
}
