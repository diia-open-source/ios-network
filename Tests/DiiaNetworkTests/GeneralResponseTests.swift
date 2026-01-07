
import XCTest
@testable import DiiaNetwork

final class GeneralResponseTests: XCTestCase {

    func testInitFromDecoder_withValidJsonData_parsesCorrectly() throws {
        // Arrange
        let jsonData = """
            {
                "error": {
                    "message": "Some error message",
                    "code": 500
                },
                "data": {
                    "name": "John",
                    "age": 30
                }
            }
            """.data(using: .utf8)

        guard let jsonData else {
            XCTFail("testInitFromDecoder_withValidJsonData_parsesCorrectly: data is not inited")
            return
        }

        let decoder = JSONDecoder()

        // Act
        let response = try decoder.decode(GeneralResponse.self, from: jsonData)

        // Assert
        let responseData = response.data as? [String: Any]
        XCTAssertNotNil(response)
        XCTAssertEqual(response.error?.localizedDescription, "Some error message")
        XCTAssertEqual(response.error, .serviceResponseData("Some error message", 500))
        XCTAssertEqual(responseData?["name"] as? String, "John")
        XCTAssertEqual(responseData?["age"] as? Int, 30)
    }

    func testInitFromDecoder_withErrorNoMessage_parsesCorrectly() throws {
        // Arrange
        let jsonData = """
            {
                "error": {
                    "code": 500
                },
                "data": {
                    "name": "John",
                    "age": 30
                }
            }
            """.data(using: .utf8)

        guard let jsonData else {
            XCTFail("testInitFromDecoder_withErrorNoMessage_parsesCorrectly: data is not inited")
            return
        }

        let decoder = JSONDecoder()

        // Act
        let response = try decoder.decode(GeneralResponse.self, from: jsonData)

        // Assert
        XCTAssertNotNil(response)
        XCTAssertEqual(response.error, .noData)
    }

    func testInitFromDecoder_withValidJsonDataAndNoError_parsesCorrectly() throws {
        // Arrange
        let jsonData = """
            {
                "error": null,
                "data": "Some string data"
            }
            """.data(using: .utf8)

        guard let jsonData else {
            XCTFail("testInitFromDecoder_withValidJsonDataAndNoError_parsesCorrectly: data is not inited")
            return
        }

        let decoder = JSONDecoder()

        // Act
        let response = try decoder.decode(GeneralResponse.self, from: jsonData)

        // Assert
        XCTAssertNotNil(response)
        XCTAssertNil(response.error)
        XCTAssertEqual(response.data as? String, "Some string data")
    }

    func testInitFromDecoder_withInvalidJsonData_throwsError() throws {
        // Arrange
        let jsonData = """
            {
                "error": {
                    "message": "Some error message,
                    "code": 500
                },
                "data": {
                    "name": "John",
                    "age": "30"
                }
            }
            """.data(using: .utf8)

        guard let jsonData else {
            XCTFail("testInitFromDecoder_withInvalidJsonData_throwsError: data is not inited")
            return
        }

        let decoder = JSONDecoder()

        // Act & Assert
        XCTAssertThrowsError(try decoder.decode(GeneralResponse.self, from: jsonData))
    }
    
    func test_rawData_withoutKeyPath() throws {
        // Arrange
        let jsonData = """
            {
                "data": {
                    "key": "value"
                }
            }
            """.data(using: .utf8)
        
        guard let jsonData else {
            XCTFail("test_rawData_withoutKeyPath: data is not inited")
            return
        }
        
        // Act & Assert
        XCTAssertNoThrow(try JSONDecoder().decode(GeneralResponse.self, from: jsonData).rawData(keyPath: nil))
    }
    
    func test_rawData_withKeyPath() throws {
        // Arrange
        let jsonData = """
            {
                "data": {
                    "root": {
                            "key": "value"
                    }
                }
            }
            """.data(using: .utf8)
        
        guard let jsonData else {
            XCTFail("test_rawData_withKeyPath: data is not inited")
            return
        }
        
        // Act & Assert
        XCTAssertNoThrow(try JSONDecoder().decode(GeneralResponse.self, from: jsonData).rawData(keyPath: "root"))
    }
    
    func test_rawData_withInvalidKeyPath() throws {
        // Arrange
        let jsonData = """
                {
                    "data": {
                        "root": {
                                "key": "value"
                        }
                    }
                }
                """.data(using: .utf8)
        
        guard let jsonData else {
            XCTFail("test_rawData_withInvalidKeyPath: data is not inited")
            return
        }
        
        // Act & Assert
        XCTAssertThrowsError(try JSONDecoder().decode(GeneralResponse.self, from: jsonData).rawData(keyPath: "invalidPath")) { error in
            XCTAssertTrue(error is NetworkError)
        }
    }
}

