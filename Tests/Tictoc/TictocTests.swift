import XCTest
@testable import Tictoc

class TictocTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Tictoc().text, "Hello, World!")
		XCTAssertTrue(Tictoc().now >= Tictoc().today.lowerBound)
		XCTAssertTrue(Tictoc().now < Tictoc().today.upperBound)
		XCTAssertTrue(Double(Tictoc().now) <= Tictoc().moment)
    }


    static var allTests : [(String, (TictocTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
