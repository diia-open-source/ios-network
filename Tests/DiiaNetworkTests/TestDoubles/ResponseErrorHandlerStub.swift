
import Foundation
@testable import DiiaNetwork

final class ResponseErrorHandlerStub: ResponseErrorHandler {
    private(set) var handleCallsCount = 0
    
    var onHandleCalled: ((RequestExecutionSteps) -> Void)?
    
    func handleError(error: NSError) {
        handleCallsCount += 1
        onHandleCalled?(.errorHandling)
    }
}

extension ResponseErrorHandlerStub: ErrorHandler {
    func handleError(_ error: NetworkError) {
        handleCallsCount += 1
        onHandleCalled?(.errorHandling)
    }
}
