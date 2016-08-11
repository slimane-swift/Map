import XCTest
@testable import Map

class MapTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(Map().text, "Hello, World!")
    }


    static var allTests : [(String, (MapTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
