import Common
import Library
import XCTest

final class TimerLabelTests: XCTestCase {
    final class MockSource: TimerSource {
        var forcedDuration: TimeInterval = 0
        var isPaused: Bool = false
        func duration() -> TimeInterval {
            forcedDuration
        }
    }

    private weak var timer: Timer!
    private var mockActiveSource: (() -> TimerSource?)?
    private var mockSource: MockSource!

    override func setUp() {
        mockSource = MockSource()
        mockActiveSource = { self.mockSource }

        let mockScheduled = { [weak self] (_: TimeInterval, _: Bool, block: @escaping (Timer) -> Void) -> Timer in
            /*
             This time interval is okay since we will be manually firing the timer,
             and don't want it to fire on its own. We need to create a Timer
             this way because `Timer()` will not return a timer unfortunately.
             (something to explore more, but this solution is good enough for a test)
             */
            let t = Timer(timeInterval: 100, repeats: true, block: block)
            self?.timer = t
            return t
        }
        Current = AppEnvironment(scheduledTimer: mockScheduled)
    }

    override func tearDown() {
        timer?.invalidate()
    }

    func testTimerStartAtZero() {
        let timerLabel = TimerLabel(frame: .zero)
        guard let timerText = timerLabel.text else {
            XCTFail("No timer text label to check")
            return
        }
        XCTAssertEqual(timerText, "00:00:00")
    }

    func testTimerStartAtZeroWithActiveSource() {
        let timerLabel = TimerLabel(frame: .zero)
        timerLabel.activeSource = mockActiveSource
        mockSource.forcedDuration = 0
        timer.fire()
        guard let timerText = timerLabel.text else {
            XCTFail("No timer text label to check")
            return
        }
        XCTAssertEqual(timerText, "00:00:00")
    }

    func testChangeDisplayTime() {
        let timerLabel = TimerLabel(frame: .zero)
        timerLabel.activeSource = mockActiveSource
        mockSource.forcedDuration = 11111
        timerLabel.refresh()
        guard let timerText = timerLabel.text else {
            XCTFail("No timer text label to check")
            return
        }
        XCTAssertEqual(timerText, "03:05:11")
    }

    func testTimerNotPaused() {
        let timerLabel = TimerLabel(frame: .zero)
        timerLabel.activeSource = mockActiveSource
        mockSource.isPaused = false
        timer.fire()

        XCTAssertNil(timerLabel.layer.animationKeys())
    }

    func testTimerPaused() {
        let timerLabel = TimerLabel(frame: .zero)
        timerLabel.activeSource = mockActiveSource
        mockSource.isPaused = true
        timer.fire()

        XCTAssertNotNil(timerLabel.layer.animationKeys())
    }
}
