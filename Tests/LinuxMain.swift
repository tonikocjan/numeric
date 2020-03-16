import XCTest
@testable import SwifyPyTests

var tests = [XCTestCaseEntry]()
tests += SwifyPyTests.allTests()
XCTMain(tests)
