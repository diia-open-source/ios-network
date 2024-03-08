import Foundation

public struct NSErrorAdapter: NSErrorHandler {
    
    public init() {
        
    }
    
    public func validateForNSError(error: Error?) throws {
        guard let error = error else {
            return
        }
        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else {
            return
        }
        
        let urlErrorCode = nsError.code
        let message: String
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
        
        throw NetworkError.nsUrlErrorDomain(message, urlErrorCode)
    }
}
