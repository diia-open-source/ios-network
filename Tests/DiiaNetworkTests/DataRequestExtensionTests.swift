
import XCTest
import ReactiveKit
import Alamofire
@testable import DiiaNetwork

class DataRequestExtensionTests: XCTestCase {
    
    // MARK: - DataRequest+Response
    func test_objectResponse_withGeneralModel() {
        // Arrange
        let dataRequest = AF.request("https://example.com")
        
        // Act
        let responseExpectation = expectation(description: "object response with GeneralModel")
        
        _ = dataRequest.responseObject(keyPath: "keyPath") { (response: AFDataResponse<GeneralResponse>) in
            // Assert
            XCTAssertNotNil(response.result)
            responseExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_objectResponse_withoutGeneralModel() {
        // Arrange
        let dataRequest = AF.request("https://example.com")
        
        // Act
        let responseExpectation = expectation(description: "object response without GeneralModel")
        
        _ = dataRequest.responseObject { (response: AFDataResponse<GeneralResponse>) in
            // Assert
            XCTAssertNotNil(response.result)
            responseExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: - DataRequest+Reactive
    
    func test_objectSignal_withGeneralResponse_completesSuccessfully() {
        // Arrange
        let dataRequest = Session.default.request("https://dummyjson.com/http/200")
        let expectation = self.expectation(description: "Object signal completes successfully")
        
        // Act
        let signal: Signal<GeneralResponse, NetworkError> = dataRequest.objectSignal()
        
        // Assert
        let disposable = signal.observeNext(with: { decodedObject in
            XCTAssertNotNil(decodedObject, "Decoded object should not be nil")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2, handler: nil)
        disposable.dispose()
    }
    
    func test_objectSignal_withGeneralResponse_completesFailure() {
        // Arrange
        let dataRequest = Session.default.request("https://dummyjson.com/http/404")
        let expectation = self.expectation(description: "Object signal completes failure")
        
        // Act
        let signal: Signal<GeneralResponse, NetworkError> = dataRequest.objectSignal()
        
        // Assert
        let disposable = signal.observeFailed(with: { decodedObject in
            XCTAssertNotNil(decodedObject, "Decoded object should not be nil")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2, handler: nil)
        disposable.dispose()
    }
    
    func test_objectSignal_withResponseNilLiteral_completesSuccessfully() {
        // Arrange
        let dataRequest = Session.default.request("https://dummyjson.com/http/200")
        let expectation = self.expectation(description: "Object signal completes failure")
        
        // Act
        let signal: Signal<ResponseNilLiteral, NetworkError> = dataRequest.objectSignal()
        
        // Assert
        let disposable = signal.observeNext(with: { decodedObject in
            XCTAssertNotNil(decodedObject, "Decoded object should not be nil")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2, handler: nil)
        disposable.dispose()
    }
    
    func test_objectSignal_withResponseNilLiteral_completesFailure() {
        // Arrange
        let dataRequest = Session.default.request("https://dummyjson.com/http/404")
        let expectation = self.expectation(description: "Object signal completes failure")
        
        // Act
        let signal: Signal<ResponseNilLiteral, NetworkError> = dataRequest.objectSignal()
        
        // Assert
        let disposable = signal.observeFailed(with: { decodedObject in
            XCTAssertNotNil(decodedObject, "Decoded object should not be nil")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2, handler: nil)
        disposable.dispose()
    }
    
    func test_addUnauthorizeValidation_worksCorrect() {
        // Arrange
        let dataRequest = Session.default.request("https://dummyjson.com/http/401")
        let expectation = self.expectation(description: "add unauthorize validation")
        
        // Act
        let validatedRequest = dataRequest.addUnautorizeValidation()
        
        // Assert
        let disposable = (validatedRequest.objectSignal() as Signal<GeneralResponse, NetworkError>).observeFailed(with: { decodedObject in
            XCTAssertNotNil(decodedObject, "Decoded object should not be nil")
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2, handler: nil)
        disposable.dispose()
    }
    
}

// MARK: - ResponseNilLiteral
struct ResponseNilLiteral: Decodable, ExpressibleByNilLiteral {
    init(nilLiteral: ()) {}
}
