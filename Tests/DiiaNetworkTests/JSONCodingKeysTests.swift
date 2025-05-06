
import XCTest
@testable import DiiaNetwork

final class JSONCodingKeysTests: XCTestCase {
    func testInit_WithStringValue() {
        let key = JSONCodingKeys(stringValue: "test_key")
        XCTAssertEqual(key?.stringValue, "test_key")
    }

    func testInit_WithIntValue() {
        let key = JSONCodingKeys(intValue: 42)
        XCTAssertEqual(key?.intValue, 42)
        XCTAssertEqual(key?.stringValue, "42")
    }

    func testInt_ValueIsNil() {
        let key = JSONCodingKeys(stringValue: "test_key")
        XCTAssertNil(key?.intValue)
    }

    func testInit_WithNegativeIntValue() {
        let key = JSONCodingKeys(intValue: -42)
        XCTAssertEqual(key?.intValue, -42)
        XCTAssertEqual(key?.stringValue, "-42")
    }
}
