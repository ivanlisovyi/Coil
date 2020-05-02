import XCTest

import CoilTests

var tests = [XCTestCaseEntry]()
tests += ContainerTests.allTests()
tests += InjectedTests.allTests()
XCTMain(tests)
