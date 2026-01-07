
import Foundation
@testable import DiiaNetwork

final class AnalyticsNetworkHandlerMock: AnalyticsNetworkHandler {
    func trackNetworkInitEvent(action: String) {}
    
    func trackNetworkResultEvent(action: String, result: String, extraData: String?) { }
}
