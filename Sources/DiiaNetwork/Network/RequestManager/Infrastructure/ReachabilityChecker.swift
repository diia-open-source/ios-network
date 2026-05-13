
import Alamofire

protocol ReachabilityChecker {
    func checkIsReachable() throws(ReachabilityCheckerError)
}

enum ReachabilityCheckerError: Error {
    case noInternet
}

final class ReachabilityCheckerImpl: ReachabilityChecker {
    func checkIsReachable() throws(ReachabilityCheckerError) {
        guard (NetworkReachabilityManager.default?.isReachable == true) else {
            throw .noInternet
        }
    }
}
