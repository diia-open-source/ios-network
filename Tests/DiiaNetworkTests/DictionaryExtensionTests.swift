
import XCTest

final class DictionaryExtensionTests: XCTestCase {

    func test_subscript_getter() {
        // Arrange
        let dictionary: [String: Any] = [
            "user": [
                "name": "Test_Name",
                "age": 40,
                "address": [
                    "city": "Test_City",
                    "zip": 10001
                ] as [String : Any]
            ] as [String : Any]
        ]

        // Assert
        XCTAssertEqual(dictionary[keyPath: "user.name"] as? String, "Test_Name")
        XCTAssertEqual(dictionary[keyPath: "user.age"] as? Int, 40)
        XCTAssertEqual(dictionary[keyPath: "user.address.city"] as? String, "Test_City")
        XCTAssertEqual(dictionary[keyPath: "user.address.zip"] as? Int, 10001)

        XCTAssertNil(dictionary[keyPath: "user.address.country"])
        XCTAssertNil(dictionary[keyPath: "nonexistent.key"])
    }

    func test_subscript_setter() {
        // Arrange
        var myDictionary: [String: Any] = [
            "name": "Test_Name",
            "age": 40,
            "address": [
                "city": "Test_City",
                "zip": 10001
            ] as [String : Any]
        ]

        // Act
        myDictionary[keyPath: "address.city" ] = "New_City"

        // Assert
        if let address = myDictionary["address"] as? [String: Any],
           let city = address["city"] as? String {
            XCTAssert(city == "New_City", "Setter test failed: Value not set correctly")
        }
    }
}
