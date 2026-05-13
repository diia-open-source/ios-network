
import Foundation

public protocol NetworkLoggerProtocol {
    func log(_ items: Any...)
}

extension NetworkLoggerProtocol {
    func logError(_ error: Error) {
        if let error = error as? DecodingError {
            switch error {
            case let .dataCorrupted(context):
                log("🔴 Request parsing error: \(context)")
            case let .keyNotFound(key, context):
                log("🔴 Request parsing error: Key '\(key)' not found: \(context.debugDescription) CodingPath: \(context.codingPath)")
            case let .valueNotFound(value, context):
                log("🔴 Request parsing error: Value '\(value)' not found: \(context.debugDescription) CodingPath: \(context.codingPath)")
            case let .typeMismatch(type, context):
                log("🔴 Request parsing error: Type '\(type)' mismatch: \(context.debugDescription) CodingPath: \(context.codingPath)")
            @unknown default:
                log("🔴 Request parsing error: \(error)")
            }
        } else {
            log("🔴 Request error: \(error)")
        }
    }
}
