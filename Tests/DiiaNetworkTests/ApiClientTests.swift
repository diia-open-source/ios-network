
import XCTest
import ReactiveKit
import Alamofire
@testable import DiiaNetwork

class ApiClientTests: XCTestCase {

    var sut: ApiClient<ApiServiceStub>!
    var progressHandler: ProgressHandlerMock!
    var errorHandler: ResponseErrorHandlerMock!

    override func setUp() {
        super.setUp()
        sut = ApiClient<ApiServiceStub>()
        progressHandler = ProgressHandlerMock()
        errorHandler = ResponseErrorHandlerMock()
        NetworkConfiguration.default.set(interceptor: RequestInterceptorMock())
        NetworkConfiguration.default.set(serverTrustPolicies: ["test": DefaultTrustEvaluator()])
    }

    override func tearDown() {
        NetworkConfiguration.default.set(interceptor: nil)
        NetworkConfiguration.default.set(serverTrustPolicies: [:])
        sut = nil
        super.tearDown()
    }

    func test_request() {
        // Arrange
        let service = ApiServiceStub()

        // Act
        let result: Signal<GeneralResponse, NetworkError> = sut.request(service)

        // Assert
        XCTAssertNotNil(result)
    }

    func test_loadRequest_withFailure() {
        // Arrange
        let service = ApiServiceStub()
        let expectation = self.expectation(description: "load request with failure")
        var isShowProgressCalled = false
        var hideProgressCalledCount = 0
        var isHandleErrorCalled = false
        progressHandler.onShowProgress = { _ in
            isShowProgressCalled.toggle()
        }
        progressHandler.onHideProgress = { _ in
            hideProgressCalledCount += 1
        }
        errorHandler.onHandleError = { _ in
            isHandleErrorCalled.toggle()
            expectation.fulfill()
        }

        // Act
        let result: SafeSignal<GeneralResponse> = sut.loadRequest(service, progressHandler: progressHandler, errorHandler: errorHandler)
        let disposable = result.observe { _ in }

        // Assert
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertNotNil(result)
        XCTAssertTrue(isShowProgressCalled)
        XCTAssertEqual(hideProgressCalledCount, 2)
        XCTAssertTrue(isHandleErrorCalled)
        disposable.dispose()
    }
}

