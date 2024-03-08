import Foundation

public protocol NSErrorHandler {
    func validateForNSError(error: Error?) throws
}
