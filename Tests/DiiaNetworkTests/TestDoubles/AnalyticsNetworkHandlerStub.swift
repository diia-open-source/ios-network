
@testable import DiiaNetwork

final class AnalyticsNetworkHandlerStub: AnalyticsNetworkHandler {
    private(set) var trackNetworkInitEventCalledCount = 0
    private(set) var trackNetworkResultEventCalledCount = 0
    
    var onSendingRequested: ((RequestExecutionSteps) -> Void)?

    func trackNetworkInitEvent(action: String) {
        trackNetworkInitEventCalledCount += 1
        onSendingRequested?(.analyticsRequestInitiatedSending)
    }
    
    func trackNetworkResultEvent(action: String, result: String, extraData: String?) {
        trackNetworkResultEventCalledCount += 1
        guard let result = AnalyticsNetworkResult(rawValue: result) else { return }
        
        switch result {
        case .success:
            onSendingRequested?(.analyticsRequestSuccessSending)
        case .fail:
            onSendingRequested?(.analyticsRequestFailSending)
        }
    }
}
