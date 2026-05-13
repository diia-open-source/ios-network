
import Foundation

protocol ResponseDomainErrorChecker {
    func domainError(from: NSError) -> NetworkError?
}

enum NSErrorAdapterError: Error {
    case domainError(message: String, urlErrorCode: Int)
    case other(error: Error)
}

public struct NSErrorAdapter {
    // MARK: - Init
    public init() {}
        
    // MARK: - Private -
    private func typedError(from error: NSError) -> NSErrorAdapterError {
        guard error.domain == NSURLErrorDomain else {
            return .other(error: error)
        }
        
        let message: String
        let urlErrorCode = error.code
        
        switch urlErrorCode {
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorDNSLookupFailed:
            message = localizedStringFor("network_error_check_internet_connection", comment: "")
        case NSURLErrorTimedOut:
            message = localizedStringFor("network_error_connection_timed_out", comment: "")
        case NSURLErrorBadURL, NSURLErrorUnsupportedURL:
            message = localizedStringFor("network_error_unable_establish_connection", comment: "")
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorHTTPTooManyRedirects:
            message = localizedStringFor("network_error_connection_timed_out", comment: "")
        case NSURLErrorDataLengthExceedsMaximum:
            message = localizedStringFor("network_error_file_is_too_large", comment: "")
        case NSURLErrorCancelled:
            message = localizedStringFor("network_error_canceled_request", comment: "")
        default:
            message = localizedStringFor("network_error_unknown_network_error", comment: "")
        }
        
        return .domainError(message: message, urlErrorCode: urlErrorCode)
    }
}

// MARK: - NSErrorAdapter + NSErrorHandler
extension NSErrorAdapter: NSErrorHandler {
    public func validateForNSError(error: Error?) throws {
        guard let error else { return }
        
        let nsError = error as NSError
        
        let errorType = typedError(from: nsError)
        
        switch errorType {
        case let .domainError(message, urlErrorCode):
            throw NetworkError.nsUrlErrorDomain(message, urlErrorCode)
        case .other:
            break
        }
    }
}

// MARK: - NSErrorAdapter + ResponseDomainErrorChecker
extension NSErrorAdapter: ResponseDomainErrorChecker {
    func domainError(from error: NSError) -> NetworkError? {
        let errorType = typedError(from: error)
        
        switch errorType {
        case let .domainError(message, urlErrorCode):
            return .nsUrlErrorDomain(message, urlErrorCode)
        case .other:
            return nil
        }
    }
}
