import XCTest
@testable import Tictoc

class TictocTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		XCTAssertTrue(NOW >= TODAY.lowerBound)
		XCTAssertTrue(NOW < TODAY.upperBound)
		XCTAssertTrue(Double(NOW) <= MOMENT)
    }


    static var allTests : [(String, (TictocTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
