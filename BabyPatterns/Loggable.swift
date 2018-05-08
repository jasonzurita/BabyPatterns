import Foundation

public enum LogType: String {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

public protocol Loggable {
    var shouldPrintDebugLog: Bool { get }
    func log(_ message: String, object: Any, type: LogType)
}

public extension Loggable {
    private var _shouldPrintDebugLog: Bool { return true }

    func log(_ message: String, object: Any, type: LogType) {
        if _shouldPrintDebugLog && shouldPrintDebugLog {
            print("\(type.rawValue) -> \(Swift.type(of: object)): " + message)
        }
    }
}
