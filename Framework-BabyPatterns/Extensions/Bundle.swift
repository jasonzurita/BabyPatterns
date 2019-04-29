import Foundation

private final class DummyClass {}

public extension Bundle {
    static var framework: Bundle {
        return Bundle(for: DummyClass.self)
    }
}
