import XCTest
@testable import Tinydux

final class TinyduxTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Tinydux().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
