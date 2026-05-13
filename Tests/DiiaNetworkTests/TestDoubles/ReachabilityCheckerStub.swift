
import Foundation
@testable import DiiaNetwork

final class ReachabilityCheckerStub: ReachabilityChecker {
    private(set) var checksCount = 0
    
    var isReachable = true
    var onReachabilityAsked: ((RequestExecutionSteps) -> Void)?
    
    func checkIsReachable() throws(ReachabilityCheckerError) {
        onReachabilityAsked?(.reachabilityChecking)
        checksCount += 1
        guard isReachable else { throw .noInternet }
    }
}
