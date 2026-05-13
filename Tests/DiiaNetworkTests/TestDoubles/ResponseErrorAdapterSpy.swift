
import Foundation
@testable import DiiaNetwork

final class ResponseErrorAdapterSpy: ResponseErrorAdapter {
    private(set) var adaptRequestCount = 0
    private let adapter: ResponseErrorAdapter
    
    var onAdaptRequested: ((RequestExecutionSteps) -> Void)?
    
    init(adaptRequestCount: Int = 0, adapter: any ResponseErrorAdapter, onAdaptRequested: ((RequestExecutionSteps) -> Void)? = nil) {
        self.adaptRequestCount = adaptRequestCount
        self.adapter = adapter
        self.onAdaptRequested = onAdaptRequested
    }

    func adaptError(_ error: Error) -> NetworkError {
        adaptRequestCount += 1
        onAdaptRequested?(.errorAdaptation)
        
        return adapter.adaptError(error)
    }
}
