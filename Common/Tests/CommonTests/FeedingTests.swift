@testable import Common
import XCTest

final class FeedingTests: XCTestCase {
    private static let typeKey = "type"
    private static let sideKey = "side"
    private static let startDateKey = "startDate"
    private static let endDateKey = "endDate"
    private static let lastPausedDateKey = "lastPausedDate"
    private static let supplyAmountKey = "supplyAmount"
    private static let pausedTimeKey = "pausedTime"

    private static let type = "Nursing"
    private static let side = 1
    private static let startDate = 12345.0
    private static let endDate = 17445.0
    private static let lastPausedDate = 16320.0
    private static let supplyAmount = 0
    private static let pausedTime = 3.0

    let jsonDict: [String: Any] = [
        FeedingTests.startDateKey: FeedingTests.startDate,
        FeedingTests.endDateKey: FeedingTests.endDate,
        FeedingTests.supplyAmountKey: FeedingTests.supplyAmount,
        FeedingTests.lastPausedDateKey: FeedingTests.lastPausedDate,
        FeedingTests.pausedTimeKey: FeedingTests.pausedTime,
        FeedingTests.sideKey: FeedingTests.side,
        FeedingTests.typeKey: FeedingTests.type,
    ]

    func testInitFromJson() {
        XCTAssertTrue(Feeding(json: jsonDict, serverKey: "blah") != nil)
    }

    func testFeedingJson() {
        guard let feeding = Feeding(json: jsonDict, serverKey: "blah") else {
            XCTFail()
            return
        }

        let json = feeding.eventJson()

        guard let type = json[FeedingTests.typeKey] as? String,
            let side = json[FeedingTests.sideKey] as? Int,
            let startDate = json[FeedingTests.startDateKey] as? Double,
            let endDate = json[FeedingTests.endDateKey] as? Double,
            let lastPausedDate = json[FeedingTests.lastPausedDateKey] as? Double,
            let amount = json[FeedingTests.supplyAmountKey] as? Int,
            let pausedTime = json[FeedingTests.pausedTimeKey] as? TimeInterval else {
            XCTFail()
            return
        }
        XCTAssertEqual(type, FeedingTests.type)
        XCTAssertEqual(side, FeedingTests.side)
        XCTAssertEqual(startDate, FeedingTests.startDate)
        XCTAssertEqual(endDate, FeedingTests.endDate)
        XCTAssertEqual(lastPausedDate, FeedingTests.lastPausedDate)
        XCTAssertEqual(amount, FeedingTests.supplyAmount)
        XCTAssertEqual(pausedTime, FeedingTests.pausedTime)
    }

    func testIsPaused() {
        guard let feeding = Feeding(json: jsonDict, serverKey: "blah") else {
            XCTFail()
            return
        }
        XCTAssertTrue(feeding.isPaused)
    }

    func testIsFinished() {
        guard let feeding = Feeding(json: jsonDict, serverKey: "blah") else {
            XCTFail()
            return
        }
        XCTAssertTrue(feeding.isFinished)
    }

    func testDuration() {
        guard let feeding = Feeding(json: jsonDict, serverKey: "blah") else {
            XCTFail()
            return
        }
        let pausedDuration = (
            FeedingTests.endDate - FeedingTests.lastPausedDate + FeedingTests.pausedTime
        )
        let duration = (
            FeedingTests.endDate - FeedingTests.startDate - pausedDuration
        )
        XCTAssertTrue(feeding.duration() == duration)
    }


    static var allTests = [
        ("testInitFromJson", testInitFromJson),
        ("testFeedingJson", testFeedingJson),
        ("testIsPaused", testIsPaused),
        ("testIsFinished", testIsFinished),
        ("testDuration", testDuration),
    ]
}
