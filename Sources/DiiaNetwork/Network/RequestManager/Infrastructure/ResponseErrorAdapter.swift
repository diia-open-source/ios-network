
import Alamofire
import Foundation

protocol ResponseErrorAdapter {
    func adaptError(_ error: Error) -> NetworkError
}

final class ResponseErrorAdapterImpl: ResponseErrorAdapter {
    private let domainErrorDetector: ResponseDomainErrorChecker
    
    // MARK: - Init
    init(domainErrorDetector: ResponseDomainErrorChecker) {
        self.domainErrorDetector = domainErrorDetector
    }
    
    // MARK: - Public
    func adaptError(_ error: Error) -> NetworkError {
        switch error {
        case let error as ReachabilityCheckerError:
            return adaptedReachabilityCheckerError(error)
        case let error as AFError:
            return adaptedAlamofireError(error)
        case let error as ResponseProviderError:
            return adaptedResponseProviderError(error)
        case let error as ResponseStatusCodeValidatorError:
            return adaptedStatusCodeValidatorError(error)
        case let error as ResponseMapperError:
            return adaptedMapperError(error)
        case let error as NSError:
            return adaptedNsUrlDomainError(error)
        }
    }
    
    // MARK: - Private -
    private func adaptedAlamofireError(_ error: AFError) -> NetworkError {
        switch error {
        case .explicitlyCancelled:
            return .cancelled
        default:
            return .anotherError(error.localizedDescription, error)
        }
    }
    
    private func adaptedStatusCodeValidatorError(_ error: ResponseStatusCodeValidatorError) -> NetworkError {
        switch error {
        case .invalidStatusCode(let statusCode):
            let description = HTTPURLResponse.localizedString(forStatusCode: statusCode).capitalized
            return .wrongStatusCode(description, statusCode, nil)
        }
    }
    
    private func adaptedReachabilityCheckerError(_ error: ReachabilityCheckerError) -> NetworkError {
        switch error {
        case .noInternet:
            return .noInternet
        }
    }
    
    private func adaptedResponseProviderError(_ error: ResponseProviderError) -> NetworkError {
        switch error {
        case .responseDoesNotExist:
            let errorModel = ErrorModel(
                processCode: -1,
                message: "No response exists"
            )
            
            return .processableError(errorModel)
        case .dataFetchingError(let error):
            return adapted(error)
        }
    }
    
    private func adapted(_ error: Error) -> NetworkError {
        if let error = error as? AFError {
            return adaptedAlamofireError(error)
        } else {
            return .anotherError(error.localizedDescription, error)
        }
    }
    
    private func adaptedMapperError(_ error: ResponseMapperError) -> NetworkError {
        switch error {
        case .mappingError(let error):
            return adapted(error)
        }
    }
    
    private func adaptedNsUrlDomainError(_ error: NSError) -> NetworkError {
        if let domainError = domainErrorDetector.domainError(from: error) {
            return domainError
        } else {
            return adapted(error)
        }
    }
}
