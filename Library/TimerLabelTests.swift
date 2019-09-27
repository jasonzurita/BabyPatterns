import Library
import XCTest

final class TimerLabelTests: XCTestCase {
    private weak var timer: Timer!

    override func setUp() {
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
        timerLabel.start(at: 0)
        guard let timerText = timerLabel.text else {
            XCTFail("No timer text label to check")
            return
        }
        XCTAssertEqual(timerText, "00:00:00")
    }

    func testChangeDisplayTime() {
        let timerLabel = TimerLabel(frame: .zero)
        timerLabel.changeDisplayTime(time: 11111)
        guard let timerText = timerLabel.text else {
            XCTFail("No timer text label to check")
            return
        }
        XCTAssertEqual(timerText, "03:05:11")
    }

    func testTimerRunning() {
        let timerLabel = TimerLabel(frame: .zero)
        timerLabel.start(at: 0)
        // simulating 5 seconds
        (1 ... 5).forEach { _ in
            timer.fire()
        }
        guard let timerText = timerLabel.text else {
            XCTFail("No timer text label to check")
            return
        }
        XCTAssertEqual(timerText, "00:00:05")
    }

    func testPauseTimer() {
        let timerLabel = TimerLabel(frame: .zero)
        timerLabel.start(at: 0)
        timerLabel.pause()
        // simulating 5 seconds
        (1 ... 10).forEach { _ in
            timer.fire()
        }
        /*
         This sleep is used to expose the bug by making the start reference time
         out of sync with the counter. 5 seconds is okay since it is a relatively
         small compared to the full CI set of tasks.
         */
        sleep(5)
        timerLabel.resume()
        timer.fire()
        guard let timerText = timerLabel.text else {
            XCTFail("No timer text label to check")
            return
        }
        XCTAssertEqual(timerText, "00:00:01")
    }
}
