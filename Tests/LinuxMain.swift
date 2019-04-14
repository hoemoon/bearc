import XCTest

import bearcTests

var tests = [XCTestCaseEntry]()
tests += bearcTests.allTests()
XCTMain(tests)