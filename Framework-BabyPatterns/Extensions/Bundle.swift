import Foundation

private final class DummyClass {}

public extension Bundle {
    public static var framework: Bundle {
        return Bundle(for: DummyClass.self)
    }
}
