import Foundation

public extension Double {
    // TODO: make these a generic function
    func stringFromSecondsToHours(zeroPadding: Bool) -> (string: String, remainder: Double) {
        let secondsToHours: Double = 3600
        let hours = floor(self / secondsToHours)
        let remainder = self - hours * secondsToHours

        var returnString = "\(Int(hours))"
        if zeroPadding && hours < 10 {
            returnString = "0\(Int(hours))"
        }

        return (returnString, remainder)
    }

    func stringFromSecondsToMinutes(zeroPadding: Bool) -> (string: String, remainder: Double) {
        let secondsToMinutes: Double = 60
        let minutes = floor(self / secondsToMinutes)
        let remainder = self - minutes * secondsToMinutes

        var returnString = "\(Int(minutes))"
        if zeroPadding && minutes < 10 {
            returnString = "0\(Int(minutes))"
        }

        return (returnString, remainder)
    }

    func stringFromSecondsToSeconds(zeroPadding: Bool) -> (string: String, remainder: Double) {
        let seconds = rounded()
        let remainder = self - seconds

        var returnString = "\(Int(seconds))"
        if zeroPadding && seconds < 10 {
            returnString = "0\(Int(seconds))"
        }

        return (returnString, remainder)
    }
}
