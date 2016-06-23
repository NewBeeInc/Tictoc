import XCTest
@testable import Tictoc

class TictocTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		XCTAssertTrue(tNow >= tToday.lowerBound)
		XCTAssertTrue(tNow < tToday.upperBound)
		XCTAssertTrue(Double(tNow) <= tMoment)
		XCTAssertTrue(tNow >= tYesterday.upperBound)
		XCTAssertTrue(tNow < tTomorrow.lowerBound)
		XCTAssertTrue(tYesterday.upperBound < tTomorrow.lowerBound)

		XCTAssertTrue(Tictoc().dayFromShortDate("2016-06-22")?.upperBound <= tToday.upperBound)
		XCTAssertTrue(Tictoc().dayFromShortDate("2016-06-22")?.lowerBound <= tToday.lowerBound)

		XCTAssertTrue(Tictoc().isTheDayToday(tToday))
		XCTAssertFalse(Tictoc().isTheDayToday(tTomorrow))
		XCTAssertFalse(Tictoc().isTheDayToday(tYesterday))

		XCTAssertTrue(Tictoc().isToday(tNow))
		XCTAssertFalse(Tictoc().isTomorrow(tNow))
    }


    static var allTests : [(String, (TictocTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
