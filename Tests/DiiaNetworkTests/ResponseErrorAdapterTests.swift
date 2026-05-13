
import Testing
import Alamofire
import Foundation
@testable import DiiaNetwork

final class ResponseErrorAdapterTests: Test {
    @Test("\"noInternet\" error if ReachabilityCheckerError.noInternet")
    func reachabilityCheckerError_noInternet() {
        assert(
            error: ReachabilityCheckerError.noInternet,
            convertedTo: .noInternet
        )
    }
    
    @Test("\"cancelled\" error if AFError.explicitlyCancelled")
    func aFError_explicitlyCancelled() {
        assert(
            error: AFError.explicitlyCancelled,
            convertedTo: .cancelled
        )
    }
    
    @Test("\"cancelled\" error if ResponseProviderError.dataFetchingError and \"cancelled\" error inside")
    func ResponseProviderError_dataFetchingError_cancelledErrorInside() {
        assert(
            error: ResponseProviderError.dataFetchingError(AFError.explicitlyCancelled),
            convertedTo: .cancelled
        )
    }
    
    @Test("\"cancelled\" error if ResponseMapperError.mappingError and \"cancelled\" error inside")
    func responseMapperError_mappingError_cancelledErrorInside() {
        assert(
            error: ResponseMapperError.mappingError(AFError.explicitlyCancelled),
            convertedTo: .cancelled
        )
    }
    
    @Test("\"anotherError\" error if ResponseMapperError.mappingError and any other error inside")
    func responseMapperError_mappingError_anotherErrorInside() {
        let anyOtherError = TestError.anyError
        let error = ResponseMapperError.mappingError(anyOtherError)
        
        assert(
            error: error,
            convertedTo: .anotherError(anyOtherError.localizedDescription, anyOtherError)
        )
    }
    
    @Test("\"anotherError\" error if any other AFError")
    func aFError_createURLRequestFailed() {
        let anyOtherAFError = AFError.createURLRequestFailed(error: NSError(domain: "test", code: 1))
        
        assert(
            error: anyOtherAFError,
            convertedTo: .anotherError(anyOtherAFError.localizedDescription, anyOtherAFError)
        )
    }
    
    @Test("\"anotherError\" error if any other Error")
    func anyOtherError() {
        let anyOtherError = TestError.anyError
        
        assert(
            error: anyOtherError,
            convertedTo: .anotherError(anyOtherError.localizedDescription, anyOtherError)
        )
    }
    
    @Test("\"anotherError\" error if ResponseProviderError.dataFetchingError and any other error inside")
    func responseProviderError_dataFetchingError_otherErrorInside() {
        let anyOtherError = TestError.anyError
        let error = ResponseProviderError.dataFetchingError(anyOtherError)
        
        assert(
            error: error,
            convertedTo: .anotherError(anyOtherError.localizedDescription, anyOtherError)
        )
    }
    
    @Test("\"anotherError\" error if ResponseMapperError.mappingError")
    func responseMapperError_mappingError() {
        let internalError = NSError(domain: "test", code: 123)
        let error = ResponseMapperError.mappingError(internalError)
        
        assert(
            error: error,
            convertedTo: .anotherError(internalError.localizedDescription, internalError)
        )
    }
    
    @Test("\"anotherError\" error if NSErrorAdapterError.other and any other error inside")
    func nSErrorAdapterError_other_otherErrorInside() {
        let anyOtherError = TestError.anyError
        let error = NSErrorAdapterError.other(error: anyOtherError)
        
        assert(
            error: error,
            convertedTo: .anotherError(anyOtherError.localizedDescription, anyOtherError)
        )
    }
    
    @Test("\"processableError\" error if ResponseProviderError.responseDoesNotExist")
    func responseProviderError_responseDoesNotExist() {
        let expectedErrorModel = ErrorModel(
            processCode: -1,
            message: "No response exists"
        )
        
        assert(
            error: ResponseProviderError.responseDoesNotExist,
            convertedTo: .processableError(expectedErrorModel)
        )
    }
    
    @Test("\"wrongStatusCode\" error if ResponseStatusCodeValidatorError.invalidStatusCode")
    func responseStatusCodeValidatorError_invalidStatusCode() {
        assert(
            error: ResponseStatusCodeValidatorError.invalidStatusCode(404),
            convertedTo: .wrongStatusCode("Not Found", 404, nil)
        )
    }
    
    @Test("\"nsUrlErrorDomain\" error if NSErrorAdapterError.domainError")
    func nSErrorAdapterError_domainError() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        let adaptedError = makeSUT().adaptError(error)
        
        switch adaptedError {
        case .nsUrlErrorDomain:
            break // Test success
        default:
            Issue.record("Error type should be \".nsUrlErrorDomain\". \(adaptedError) instead")
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> ResponseErrorAdapter {
        let nSErrorAdapter = NSErrorAdapter()
        let adapter = ResponseErrorAdapterImpl(domainErrorDetector: nSErrorAdapter)
        
        trackForMemoryLeaks(adapter, file: file, line: line)
        
        return adapter
    }
    
    private func assert(
        error: any Error,
        convertedTo expectedError: NetworkError,
        _ sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let adaptedError = makeSUT().adaptError(error)
        #expect(adaptedError == expectedError, sourceLocation: sourceLocation)
    }
}

private enum TestError: Error {
    case anyError
}
