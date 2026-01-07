
import Foundation
@testable import DiiaNetwork

final class ResponseErrorHandlerMock: ResponseErrorHandler {
    var onHandleError: ((Bool) -> Void)?
    
    func handleError(error: NSError) {
        onHandleError?(true)
    }
}

extension ResponseErrorHandlerMock: ErrorHandler {
    func handleError(_ error: NetworkError) {
        onHandleError?(true)
    }
}
