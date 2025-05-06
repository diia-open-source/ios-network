
import Foundation

public protocol NetworkLoggerProtocol {
    func log(_ items: Any...)
}

struct PrintLogger: NetworkLoggerProtocol {
    func log(_ items: Any...) {
        items.forEach { print($0) }
    }
}
