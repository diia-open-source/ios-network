
import Foundation
@testable import DiiaNetwork

class NetworkLoggerMock: NetworkLoggerProtocol {
    func log(_ items: Any...) {
        items.forEach { print($0) }
    }
}

