import XCTest

import CycleTests

var tests = [XCTestCaseEntry]()
tests += CycleTests.allTests()
XCTMain(tests)
