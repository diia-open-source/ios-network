import XCTest
@testable import DiiaNetwork

class NetworkResponseHandlerTests: XCTestCase {

    func testParseGeneralModel() {
        // Arrange
        let handler = NetworkResponseHandler<GeneralResponse>()
        let jsonData = """
        {
            "key": "value"
        }
        """.data(using: .utf8)
        
        // Act
        XCTAssertNoThrow(try handler.parseGeneralModel(from: jsonData))
    }

    func testParseWithInvalidData() {
        // Arrange
        let handler = NetworkResponseHandler<GeneralResponse>()
        let jsonData: Data? = nil
        
        // Act & Assert
        XCTAssertThrowsError(try handler.parseGeneralModel(from: jsonData)) { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.noData)
        }
    }

    func testValidateHTTPStatusCodeSuccessWithOkStatus() {
        // Arrange
        let handler = NetworkResponseHandler<GeneralResponse>()
        
        // Act & Assert
        XCTAssertNoThrow(try handler.validateHTTPStatusCodeSuccess(statusCode: 200, responseError: nil))
    }

    func testValidateHTTPStatusCodeSuccessWithCreatedStatus() {
        // Arrange
        let handler = NetworkResponseHandler<GeneralResponse>()
        
        // Act & Assert
        XCTAssertNoThrow(try handler.validateHTTPStatusCodeSuccess(statusCode: 201, responseError: nil))
    }

    func testValidateHTTPStatusCodeSuccessWithInvalidStatus() {
        // Arrange
        let handler = NetworkResponseHandler<GeneralResponse>()
        
        // Act & Assert
        XCTAssertThrowsError(try handler.validateHTTPStatusCodeSuccess(statusCode: 404, responseError: nil)) { error in
            XCTAssertEqual(error as? NetworkError, NetworkError.wrongStatusCode("Not Found", 404, nil))
        }
    }
    
    func test_processResponse_withErrorResponseHandler() {
        // Arrange
        let handler = NetworkResponseHandler<GeneralResponse>()
        let errorHandler = ResponseErrorHandlerMock()
        NetworkConfiguration.default.set(responseErrorHandler: errorHandler)
        
        let expectation = self.expectation(description: "process response with ErrorResponseHandler")
        var isHandleErrorCalled = false
        errorHandler.onHandleError = { _ in
            isHandleErrorCalled.toggle()
            expectation.fulfill()
        }
        
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)
        let errorData = """
            {
                "error": "Not Found"
            }
            """.data(using: .utf8)
        
        // Act & Assert
        XCTAssertThrowsError(try handler.processResponse(response, error: nil, responseData: errorData, keyPath: nil))
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(isHandleErrorCalled)
    }
    
    func testProcessResponseWithKeyPath() {
        // Arrange
        let handler = NetworkResponseHandler<GeneralResponse>()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let jsonData = """
            {
                "data": {
                    "key": "value"
                }
            }
            """.data(using: .utf8)
        
        // Act
        XCTAssertNoThrow(try handler.processResponse(response, error: nil, responseData: jsonData, keyPath: "data"))
    }
    
    func testSuccessHandlingResponse() {
        // Arrange
        let handler = NetworkResponseHandler<GeneralResponse>()
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let jsonData = """
            {
                "data": {
                    "key": "value"
                }
            }
            """.data(using: .utf8)
        
        // Act
        XCTAssertNoThrow(try handler.successHandlingResponse(response, error: nil, responseData: jsonData, keyPath: nil) as GeneralResponse)
    }
    
    func testFailedHandlingResponseWithLogging() {
        // Arrange
        let handler = NetworkResponseHandler<GeneralResponse>()
        NetworkConfiguration.default.set(logging: true)
        let error = NSError(domain: "https://example.com", code: 500, userInfo: ["message": "Internal Server Error"])
        
        // Act & Assert
        XCTAssertNoThrow(handler.failedHandlingResponse(error: error))
    }
}
