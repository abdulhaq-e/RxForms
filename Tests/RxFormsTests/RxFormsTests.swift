import XCTest
@testable import RxForms

final class RxFormsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RxForms().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
