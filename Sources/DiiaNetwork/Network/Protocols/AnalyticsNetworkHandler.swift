import Foundation

public protocol AnalyticsNetworkHandler {
    func trackNetworkInitEvent(action: String)
    func trackNetworkResultEvent(action: String, result: String, extraData: String?)
}

// MARK: - internal AnalyticsResult
enum AnalyticsNetworkResult: String {
    case success
    case fail
}
