
import XCTest
import ReactiveKit
import Alamofire
@testable import DiiaNetwork

final class ApiClientTests: Test {
    override func setUp() {
        super.setUp()
        NetworkConfiguration.default.set(interceptor: RequestInterceptorMock())
        NetworkConfiguration.default.set(serverTrustPolicies: [ValidTestApiServiceStub.domain: DefaultTrustEvaluator()])
    }

    override func tearDown() {
        NetworkConfiguration.default.set(interceptor: nil)
        NetworkConfiguration.default.set(serverTrustPolicies: [:])
        super.tearDown()
    }

    // MARK: - Reactive API tests
    func test_reactive_requestSignalReturned() {
        let anyService = InvalidTestApiServiceStub()
        let sut: SUT<InvalidTestApiServiceStub> = makeSut()

        let signal: Signal<GeneralResponse, NetworkError> = sut.apiClient.request(anyService)

        XCTAssertNotNil(signal)
    }
    
    func test_reactiveWithHandlers_requestSignalReturned() {
        let anyService = InvalidTestApiServiceStub()
        let sut: SUT<InvalidTestApiServiceStub> = makeSut()

        let signal: SafeSignal<GeneralResponse> = sut.apiClient.request(
            anyService,
            progressHandler: sut.progressHandler,
            errorHandler: sut.errorHandler
        )

        XCTAssertNotNil(signal)
    }
    
    func test_reactive_requestSucceed() {
        let validService = ValidTestApiServiceStub()
        let sut: SUT<ValidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Callback should be called")
        var value: ValidTestApiServiceStubModel?
        
        let signal: Signal<ValidTestApiServiceStubModel, NetworkError> = sut.apiClient.request(validService)

        let disposable = signal.observe { next in
            switch next {
            case .next(let _value):
                value = _value
                expectation.fulfill()
            case .failed:
                XCTFail("Expected to throw an error")
            case .completed:
                break
            }
        }

        waitForExpectations(timeout: 2)
        XCTAssertNotNil(value)
        disposable.dispose()
    }
    
    func test_reactiveWithHandlers_requestSucceed() {
        let validService = ValidTestApiServiceStub()
        let sut: SUT<ValidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Callback should be called")
        var value: ValidTestApiServiceStubModel?
        
        let signal: SafeSignal<ValidTestApiServiceStubModel> = sut.apiClient.request(
            validService,
            progressHandler: sut.progressHandler,
            errorHandler: sut.errorHandler
        )

        let disposable = signal.observe { next in
            switch next {
            case .next(let _value):
                value = _value
                expectation.fulfill()
            case .failed:
                XCTFail("Expected to throw an error")
            case .completed:
                break
            }
        }

        waitForExpectations(timeout: 2)
        XCTAssertNotNil(value)
        disposable.dispose()
    }
    
    func test_reactive_requestFailed() {
        let invalidService = InvalidTestApiServiceStub()
        let sut: SUT<InvalidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Callback should be called")
        let signal: Signal<AnyType, NetworkError> = sut.apiClient.request(invalidService)

        let disposable = signal.observe { next in
            switch next {
            case .next:
                XCTFail("Expected an error")
            case .failed:
                expectation.fulfill()
            case .completed:
                break
            }
        }

        waitForExpectations(timeout: 2)
        disposable.dispose()
    }
    
    func test_reactiveWithHandlers_requestFailed() {
        let invalidService = InvalidTestApiServiceStub()
        let sut: SUT<InvalidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Callback should be called")
        
        sut.errorHandler.onHandleCalled = { _ in
            expectation.fulfill()
        }
        
        let signal: SafeSignal<AnyType> = sut.apiClient.request(
            invalidService,
            progressHandler: sut.progressHandler,
            errorHandler: sut.errorHandler
        )

        let disposable = signal.observe { _ in }

        waitForExpectations(timeout: 2)
        disposable.dispose()
    }
    
    func test_reactiveWithHandlers_processHandlerCalledCorrectly_ifRequestSucceed() {
        let validService = ValidTestApiServiceStub()
        let sut: SUT<ValidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Callback should be called")

        var countOfOnShowProgressCalls = 0
        var countOfOnHideProgressCalls = 0

        sut.progressHandler.onShowProgress = {
            countOfOnShowProgressCalls += 1
        }
        
        sut.progressHandler.onHideProgress = {
            countOfOnHideProgressCalls += 1
        }
        
        let signal: SafeSignal<ValidTestApiServiceStubModel> = sut.apiClient.request(
            validService,
            progressHandler: sut.progressHandler,
            errorHandler: sut.errorHandler
        )
        
        let disposable = signal.observe { next in
            switch next {
            case .next:
                XCTAssertEqual(countOfOnShowProgressCalls, 1)
                XCTAssertEqual(countOfOnHideProgressCalls, 1)
            case .failed:
                XCTFail("Should not be failed")
            case .completed:
                XCTAssertEqual(countOfOnShowProgressCalls, 1)
                XCTAssertEqual(countOfOnHideProgressCalls, 3)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 2)
        disposable.dispose()
    }
    
    func test_reactiveWithHandlers_processHandlerCalledCorrectly_ifRequestFailed() {
        let invalidService = InvalidTestApiServiceStub()
        let sut: SUT<InvalidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Callback should be called")

        var countOfOnShowProgressCalls = 0
        var countOfOnHideProgressCalls = 0

        sut.progressHandler.onShowProgress = {
            countOfOnShowProgressCalls += 1
        }
        
        sut.progressHandler.onHideProgress = {
            countOfOnHideProgressCalls += 1
        }
        
        sut.errorHandler.onHandleCalled = { _ in
            expectation.fulfill()
        }
        
        let signal: SafeSignal<AnyType> = sut.apiClient.request(
            invalidService,
            progressHandler: sut.progressHandler,
            errorHandler: sut.errorHandler
        )
        
        let disposable = signal.observe { next in
            switch next {
            case .next, .completed:
                XCTFail("These cases should not be called")
            case .failed:
                XCTFail("Error should be handled using errorHandler")
            }
        }
        
        waitForExpectations(timeout: 2)
        
        XCTAssertEqual(countOfOnShowProgressCalls, 1)
        XCTAssertEqual(countOfOnHideProgressCalls, 2)
        
        disposable.dispose()
    }
    
    // MARK: - Async API tests
    func test_async_requestSucceed() async {
        let validService = ValidTestApiServiceStub()
        let sut: SUT<ValidTestApiServiceStub> = makeSut()
        
        do {
            let _: ValidTestApiServiceStubModel = try await sut.apiClient.request(validService)
        } catch {
            XCTFail("No errors expected. Error: \(error.localizedDescription)")
        }
    }
    
    func test_async_requestFailed() async {
        let invalidService = InvalidTestApiServiceStub()
        let sut: SUT<InvalidTestApiServiceStub> = makeSut()
        
        do {
            let _: AnyType? = try await sut.apiClient.request(invalidService)
            XCTFail("Expected to throw an error")
        } catch {}
    }
    
    // MARK: - Callbacks API tests
    func test_completionCallback_requestSucceed() throws {
        let validService = ValidTestApiServiceStub()
        let sut: SUT<ValidTestApiServiceStub> = makeSut()
        
        let expectation = self.expectation(description: "Completion callback should be called")
        
        var result: Result<ValidTestApiServiceStubModel, NetworkError>?

        sut.apiClient.request(validService, completion: { (_result: Result<ValidTestApiServiceStubModel, NetworkError>) in
            result = _result
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0)
        
        let unwrappedResult = try XCTUnwrap(result)
                
        switch unwrappedResult {
        case .success:
            break
        case .failure:
            XCTFail("Result should be successful")
        }
    }
    
    func test_completionCallback_requestFailed() throws {
        let invalidService = InvalidTestApiServiceStub()
        let sut: SUT<InvalidTestApiServiceStub> = makeSut()
        
        let expectation = self.expectation(description: "Completion callback should be called")
        
        var result: Result<AnyType, NetworkError>?

        sut.apiClient.request(invalidService, completion: { (_result: Result<AnyType, NetworkError>) in
            result = _result
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 2.0)
        
        let unwrappedResult = try XCTUnwrap(result)
                
        switch unwrappedResult {
        case .success:
            XCTFail("Result should be failed")
        case .failure:
            break
        }
    }
    
    func test_separatedCallbacks_requestSucceed() {
        let validService = ValidTestApiServiceStub()
        let sut: SUT<ValidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Any of completion callbacks should be called")
        
        var value: ValidTestApiServiceStubModel?
        
        sut.apiClient.request(
            validService,
            onSuccess: { (_value: ValidTestApiServiceStubModel) in
                value = _value
                expectation.fulfill()
            }, onFailure: { (_: NetworkError) in
                expectation.fulfill()
            })
        
        waitForExpectations(timeout: 2.0)
        
        XCTAssertNotNil(value)
    }
    
    func test_separatedCallbacks_requestFailed() {
        let invalidService = InvalidTestApiServiceStub()
        let sut: SUT<InvalidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Any of completion callbacks should be called")
        
        var error: NetworkError?
        
        sut.apiClient.request(
            invalidService,
            onSuccess: { (_: AnyType) in
                expectation.fulfill()
            }, onFailure: { (_error: NetworkError) in
                error = _error
                expectation.fulfill()
            })
        
        waitForExpectations(timeout: 2.0)
        
        XCTAssertNotNil(error)
    }
    
    // MARK: - Handlers API tests
    func test_handlers_requestSucceed() {
        let validService = ValidTestApiServiceStub()
        let sut: SUT<ValidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Completion callback should be called")
        
        var value: ValidTestApiServiceStubModel?
        
        sut.apiClient.request(
            validService,
            progressHandler: sut.progressHandler,
            errorHandler: sut.errorHandler) { _value in
                value = _value
                expectation.fulfill()
            }
        
        waitForExpectations(timeout: 2.0)
        
        XCTAssertNotNil(value)
    }
    
    func test_handlers_processHandlerCalledCorrectly_ifRequestSucceed() {
        let validService = ValidTestApiServiceStub()
        let sut: SUT<ValidTestApiServiceStub> = makeSut()
        
        var countOfOnShowProgressCalls = 0
        var countOfOnHideProgressCalls = 0

        sut.progressHandler.onShowProgress = {
            countOfOnShowProgressCalls += 1
        }
        
        sut.progressHandler.onHideProgress = {
            countOfOnHideProgressCalls += 1
        }
        
        sut.apiClient.request(
            validService,
            progressHandler: sut.progressHandler,
            errorHandler: sut.errorHandler) { (_: AnyType) in
                XCTAssertEqual(countOfOnShowProgressCalls, 1)
                XCTAssertEqual(countOfOnHideProgressCalls, 1)
            }
    }
    
    func test_handlers_requestFailed() {
        let invalidService = InvalidTestApiServiceStub()
        let sut: SUT<InvalidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Completion callback should be called")
                
        sut.errorHandler.onHandleCalled = { _ in
            expectation.fulfill()
        }

        sut.apiClient.request(
            invalidService,
            progressHandler: sut.progressHandler,
            errorHandler: sut.errorHandler) { (_: AnyType) in
                XCTFail("Completion should not be called")
            }
        
        waitForExpectations(timeout: 2.0)
        
        XCTAssertEqual(sut.errorHandler.handleCallsCount, 1, "Error should be handled")
    }
    
    func test_handlers_processHandlerCalledCorrectly_ifRequestFailed() {
        let invalidService = InvalidTestApiServiceStub()
        let sut: SUT<InvalidTestApiServiceStub> = makeSut()
        let expectation = self.expectation(description: "Completion callback should be called")
        
        var countOfOnShowProgressCalls = 0
        var countOfOnHideProgressCalls = 0
                
        sut.errorHandler.onHandleCalled = { _ in
            expectation.fulfill()
        }
        
        sut.progressHandler.onShowProgress = {
            countOfOnShowProgressCalls += 1
        }
        
        sut.progressHandler.onHideProgress = {
            countOfOnHideProgressCalls += 1
        }
        
        sut.apiClient.request(
            invalidService,
            progressHandler: sut.progressHandler,
            errorHandler: sut.errorHandler) { (_: AnyType) in
                XCTFail("Completion should not be called")
            }
        
        waitForExpectations(timeout: 2.0)
        
        XCTAssertEqual(sut.errorHandler.handleCallsCount, 1, "Error should be handled")
        XCTAssertEqual(countOfOnShowProgressCalls, 1)
        XCTAssertEqual(countOfOnHideProgressCalls, 1)
    }
    
    // MARK: - Helpers
    private let anyErrorHandler: ErrorHandler? = nil
    private let anyProgressHandler: ProgressHandler? = nil
    
    private func makeSut<T: CommonService>(file: StaticString = #filePath, line: UInt = #line) -> SUT<T> {
        let apiClient = ApiClient<T>()
        let progressHandler = ProgressHandlerMock()
        let errorHandler = ResponseErrorHandlerStub()
        
        trackForMemoryLeaks(apiClient, file: file, line: line)
        trackForMemoryLeaks(errorHandler, file: file, line: line)
        trackForMemoryLeaks(progressHandler, file: file, line: line)
        
        return SUT(
            apiClient: apiClient,
            progressHandler: progressHandler,
            errorHandler: errorHandler
        )
    }
}

private final class SUT<T: CommonService> {
    init(
        apiClient: ApiClient<T>,
        progressHandler: ProgressHandlerMock,
        errorHandler: ResponseErrorHandlerStub
    ) {
        self.apiClient = apiClient
        self.errorHandler = errorHandler
        self.progressHandler = progressHandler
    }
    
    let apiClient: ApiClient<T>
    let progressHandler: ProgressHandlerMock
    let errorHandler: ResponseErrorHandlerStub
}

private struct ValidTestApiServiceStubModel: Decodable {
    let status: Int
    let message: String
}

private struct AnyType: Decodable {}
