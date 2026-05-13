
import Testing
import Alamofire
import Foundation
@testable import DiiaNetwork

final class RequestManagerTests: Test {
    @Test("Network reachability is checked")
    func networkReachabilityChecked() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.reachabilityChecker.checksCount != 0)
    }
    
    @Test("Network reachability checked once")
    func networkReachabilityCheckedOnce() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.reachabilityChecker.checksCount == 1)
    }
    
    @Test("Response requested")
    func responseRequested() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.responseProvider.responseRequestsCount != 0)
    }
    
    @Test("Response requested once")
    func responseRequestedOnce() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.responseProvider.responseRequestsCount == 1)
    }
    
    @Test("Status code checked")
    func statusCodeChecked() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.statusCodeValidator.callsCount != 0)
    }
    
    @Test("Status code checked once")
    func statusCodeCheckedOnce() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.statusCodeValidator.callsCount == 1)
    }
    
    @Test("Data was mapped")
    func dataWasMapped() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.responseMapper.mapCallsCount != 0)
    }
    
    @Test("Data was mapped once")
    func dataWasMappedOnce() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.responseMapper.mapCallsCount != 0)
    }
    
    @Test("Analytics when request initialized sent")
    func analyticsWhenRequestInitializedSent() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.analyticsCollector?.trackNetworkInitEventCalledCount != 0)
    }
    
    @Test("Analytics when request initialized sent once")
    func analyticsWhenRequestInitializedSentOnce() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.analyticsCollector?.trackNetworkInitEventCalledCount == 1)
    }
    
    @Test("Analytics when request success sent")
    func analyticsWhenRequestSuccessSent() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.analyticsCollector?.trackNetworkResultEventCalledCount != 0)
    }
    
    @Test("Analytics when request success sent once")
    func analyticsWhenRequestSuccessSentOnce() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.analyticsCollector?.trackNetworkResultEventCalledCount == 1)
    }
    
    @Test("Analytics when request failed sent")
    func analyticsWhenRequestFailedSent() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.analyticsCollector?.trackNetworkResultEventCalledCount != 0)
    }
    
    @Test("Analytics when request failed sent once")
    func analyticsWhenRequestFailedSentOnce() async throws {
        let sut = try makeSUT(isReachable: false)
        try? await performValidRequest(in: sut)
        #expect(sut.analyticsCollector?.trackNetworkResultEventCalledCount == 1)
    }
    
    @Test("Error passed to error handler")
    func errorPassedToErrorHandler() async throws {
        let sut = try makeSUT(isReachable: false)
        try? await performValidRequest(in: sut)
        #expect(sut.responseErrorHandler?.handleCallsCount != 0)
    }
    
    @Test("Error passed to error handler once")
    func errorPassedToErrorHandlerOnce() async throws {
        let sut = try makeSUT(isReachable: false)
        try? await performValidRequest(in: sut)
        #expect(sut.responseErrorHandler?.handleCallsCount == 1)
    }
    
    @Test("Error adaptation called")
    func errorAdaptationCalled() async throws {
        let sut = try makeSUT(isReachable: false)
        try? await performValidRequest(in: sut)
        #expect(sut.responseErrorAdapter.adaptRequestCount != 0)
    }
    
    @Test("Error adaptation called once")
    func errorAdaptationCalledOnce() async throws {
        let sut = try makeSUT(isReachable: false)
        try? await performValidRequest(in: sut)
        #expect(sut.responseErrorAdapter.adaptRequestCount == 1)
    }
    
    @Test("Response logged")
    func responseLogged() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.logger?.callsCount != 0)
    }
    
    @Test("Response logged correctly")
    func responseLoggedCorrectly() async throws {
        let sut = try makeSUT()
        try await performValidRequest(in: sut)
        #expect(sut.logger?.callsCount == 3)
    }
    
    @Test("Error logged")
    func errorLogged() async throws {
        let sut = try makeSUT(isReachable: false)
        try? await performValidRequest(in: sut)
        #expect(sut.logger?.callsCount != 0)
    }
    
    @Test("Error logged once")
    func errorLoggedOnce() async throws {
        let sut = try makeSUT(isReachable: false)
        try? await performValidRequest(in: sut)
        #expect(sut.logger?.callsCount == 1)
    }
        
    @Test("Request performed in proper order if success")
    func requestPerformedInProperOrderIfSuccess() async throws {
        let sut = try makeSUT()
        let dataRequest = makeTestDataRequest()
        
        var performedSteps: [RequestExecutionSteps] = []
        
        sut.reachabilityChecker.onReachabilityAsked = { step in performedSteps.append(step) }
        sut.responseProvider.onResponseRequested = { step in performedSteps.append(step) }
        sut.logger?.onLoggingRequested = { step in performedSteps.append(step) }
        sut.analyticsCollector?.onSendingRequested = { step in performedSteps.append(step) }
        sut.statusCodeValidator.onValidationAsked = { step in performedSteps.append(step) }
        sut.responseMapper.onMapRequested = { step in performedSteps.append(step) }

        try await perform(dataRequest, in: sut)
        
        #expect(
            performedSteps == [
                .reachabilityChecking,
                .analyticsRequestInitiatedSending,
                .responseFetching,
                .logging,
                .logging,
                .logging,
                .statusCodeValidation,
                .dataMapping,
                .analyticsRequestSuccessSending
            ]
        )
    }
    
    @Test("Request performed in proper order if failure")
    func requestPerformedInProperOrderIfFailure() async throws {
        let sut = try makeSUT(isReachable: false)
        let dataRequest = makeTestDataRequest()
        
        var performedSteps: [RequestExecutionSteps] = []
        
        sut.reachabilityChecker.onReachabilityAsked = { step in performedSteps.append(step) }
        sut.responseErrorAdapter.onAdaptRequested = { step in performedSteps.append(step) }
        sut.responseErrorHandler?.onHandleCalled = { step in performedSteps.append(step) }
        sut.logger?.onLoggingRequested = { step in performedSteps.append(step) }
        sut.analyticsCollector?.onSendingRequested = { step in performedSteps.append(step) }

        try? await perform(dataRequest, in: sut)
        
        #expect(
            performedSteps == [
                .reachabilityChecking,
                .errorAdaptation,
                .errorHandling,
                .analyticsRequestFailSending,
                .logging
            ]
        )
    }
    
    @Test("An error thrown when request cancelled")
    func anErrorThrownWhenRequestCancelled() async throws {
        let sut = try makeSUT(cancelRequest: true)

        await #expect(throws: anyErrorType) {
            try await performValidRequest(in: sut)
        }
    }
    
    @Test("Correct error thrown when request cancelled")
    func correctErrorThrownWhenRequestCancelled() async throws {
        let sut = try makeSUT(cancelRequest: true)

        await #expect(throws: NetworkError.cancelled) {
            try await performValidRequest(in: sut)
        }
    }
    
    @Test("Error does not handle if request cancelled")
    func errorDoesNotHandleIfRequestCancelled() async throws {
        let sut = try makeSUT(cancelRequest: true)
        var errorHandlingCalled = false
        
        let responseErrorHandler = try #require(sut.responseErrorHandler)
        
        responseErrorHandler.onHandleCalled = { _ in
            errorHandlingCalled = true
        }
        
        try? await performValidRequest(in: sut)
        #expect(errorHandlingCalled == false)
    }
    
    @Test("Analytic does not send if request cancelled")
    func analyticDoesNotSendIfRequestCancelled() async throws {
        let sut = try makeSUT(cancelRequest: true)
        var analyticsSent = false
        
        let analyticsCollector = try #require(sut.analyticsCollector)
        
        analyticsCollector.onSendingRequested = { step in
            switch step {
            case .analyticsRequestFailSending:
                analyticsSent = true
            default:
                break
            }
        }
        
        try? await performValidRequest(in: sut)
        #expect(analyticsSent == false)
    }
    
    @Test("Next step does not performed when no internet connection")
    func nextStepDoesNotPerformedWhenNoInternetConnection() async throws {
        let sut = try makeSUT(isReachable: false)
        var nextStepSent = false
        
        let analyticsCollector = try #require(sut.analyticsCollector)
        
        analyticsCollector.onSendingRequested = { step in
            switch step {
            case .analyticsRequestInitiatedSending:
                nextStepSent = true
            default:
                break
            }
        }
        
        try? await performValidRequest(in: sut)
        #expect(nextStepSent == false)
    }
    
    @Test("Next step does not performed if cancelled during response getting")
    func nextStepDoesNotPerformedIfCancelledDuringResponseGetting() async throws {
        let sut = try makeSUT(cancelRequest: true)
        var nextStepSent = false
        
        let analyticsCollector = try #require(sut.analyticsCollector)

        analyticsCollector.onSendingRequested = { step in
            switch step {
            case .analyticsRequestFailSending:
                nextStepSent = true
            default:
                break
            }
        }
        
        try? await performValidRequest(in: sut)
        #expect(nextStepSent == false)
    }

    // MARK: - Helpers
    private let anyValidResponseJSONData = """
            {
                "id": 1
            }
            """
    
    private func makeSUT(
        isReachable: Bool = true,
        cancelRequest: Bool = false,
        _ sourceLocation: SourceLocation = #_sourceLocation
    ) throws -> SUT {
        let jsonData = try #require(anyValidResponseJSONData.data(using: .utf8), sourceLocation: sourceLocation)
        
        let logger = NetworkLoggerStub()
        let nSErrorAdapter = NSErrorAdapter()
        let responseProvider = ResponseProviderStub(responseData: jsonData)
        let reachabilityChecker = ReachabilityCheckerStub()
        let analyticsCollector = AnalyticsNetworkHandlerStub()
        let responseErrorHandler = ResponseErrorHandlerStub()
        let statusCodeValidator = ResponseStatusCodeValidatorStub()
        let responseMapper = ResponseMapperImpl(decoder: JSONDecoderConfigMock())
        let responseMapperSpy = ResponseMapperSpy(mapper: responseMapper)
        let responseErrorAdapter = ResponseErrorAdapterImpl(domainErrorDetector: nSErrorAdapter)
        let responseErrorAdapterSpy = ResponseErrorAdapterSpy(adapter: responseErrorAdapter)
        
        trackForMemoryLeaks(logger, sourceLocation)
        trackForMemoryLeaks(responseProvider, sourceLocation)
        trackForMemoryLeaks(reachabilityChecker, sourceLocation)
        trackForMemoryLeaks(statusCodeValidator, sourceLocation)
        trackForMemoryLeaks(responseMapper, sourceLocation)
        trackForMemoryLeaks(responseMapperSpy, sourceLocation)
        trackForMemoryLeaks(responseErrorAdapter, sourceLocation)
        trackForMemoryLeaks(responseErrorAdapterSpy, sourceLocation)
        trackForMemoryLeaks(analyticsCollector, sourceLocation)

        reachabilityChecker.isReachable = isReachable
        
        if cancelRequest {
            responseProvider.errorToThrow = .dataFetchingError(AFError.explicitlyCancelled)
        }

        return SUT(
            logger: logger,
            responseMapper: responseMapperSpy,
            responseProvider: responseProvider,
            reachabilityChecker: reachabilityChecker,
            responseErrorAdapter: responseErrorAdapterSpy,
            responseErrorHandler: responseErrorHandler,
            analyticsCollector: analyticsCollector,
            statusCodeValidator: statusCodeValidator
        )
    }
    
    private func makeTestDataRequest() -> DataRequest {
        let service = ApiServiceStub()
        let apiClient = ApiClient<ApiServiceStub>()
        let request = apiClient.sessionManager.request(service)

        return request
    }
    
    private func performValidRequest(in sut: SUT) async throws {
        let dataRequest = makeTestDataRequest()
        try await perform(dataRequest, in: sut)
    }
    
    private func perform(_ dataRequest: DataRequest, in sut: SUT) async throws {
        let _: [String: Int] = try await sut.requestManager.perform(dataRequest)
    }
}

private final class SUT {
    let requestManager: RequestManager
    
    let logger: NetworkLoggerStub?
    let responseErrorHandler: ResponseErrorHandlerStub?
    let analyticsCollector: AnalyticsNetworkHandlerStub?
    let responseMapper: ResponseMapperSpy
    let responseProvider: ResponseProviderStub
    let reachabilityChecker: ReachabilityCheckerStub
    let responseErrorAdapter: ResponseErrorAdapterSpy
    let statusCodeValidator: ResponseStatusCodeValidatorStub
    
    init(
        logger: NetworkLoggerStub?,
        responseMapper: ResponseMapperSpy,
        responseProvider: ResponseProviderStub,
        reachabilityChecker: ReachabilityCheckerStub,
        responseErrorAdapter: ResponseErrorAdapterSpy,
        responseErrorHandler: ResponseErrorHandlerStub?,
        analyticsCollector: AnalyticsNetworkHandlerStub?,
        statusCodeValidator: ResponseStatusCodeValidatorStub
    ) {
        self.logger = logger
        self.responseMapper = responseMapper
        self.responseProvider = responseProvider
        self.analyticsCollector = analyticsCollector
        self.statusCodeValidator = statusCodeValidator
        self.reachabilityChecker = reachabilityChecker
        self.responseErrorHandler = responseErrorHandler
        self.responseErrorAdapter = responseErrorAdapter
        
        self.requestManager = RequestManager(
            logger: logger,
            responseMapper: responseMapper,
            responseProvider: responseProvider,
            reachabilityChecker: reachabilityChecker,
            responseErrorAdapter: responseErrorAdapter,
            responseErrorHandler: responseErrorHandler,
            analyticsCollector: analyticsCollector,
            statusCodeValidator: statusCodeValidator
        )
    }
}

enum RequestExecutionSteps {
    case reachabilityChecking
    case analyticsRequestInitiatedSending
    case responseFetching
    case logging
    case statusCodeValidation
    case dataMapping
    case analyticsRequestSuccessSending
    case analyticsRequestFailSending
    case errorHandling
    case errorAdaptation
}
