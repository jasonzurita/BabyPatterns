import XCTest
@testable import Cycle

final class CycleTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Cycle().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
