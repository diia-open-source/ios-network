
@testable import DiiaNetwork

final class NetworkLoggerStub: NetworkLoggerProtocol {
    private(set) var callsCount = 0
    
    var onLoggingRequested: ((RequestExecutionSteps) -> Void)?
    
    func log(_ items: Any...) {
        callsCount += 1
        onLoggingRequested?(.logging)
    }
}
