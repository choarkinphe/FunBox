import XCTest
@testable import FunBox

final class FunBoxTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FunBox().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
