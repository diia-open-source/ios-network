
import Foundation

protocol ResponseStatusCodeValidator {
    func checkIsStatusCodeValid(inResponse response: HTTPURLResponse) throws(ResponseStatusCodeValidatorError)
}

enum ResponseStatusCodeValidatorError: Error {
    case invalidStatusCode(Int)
}

struct ResponseStatusCodeValidatorConfig {
    let validStatusCodes: [Int]
}

final class ResponseStatusCodeValidatorImpl: ResponseStatusCodeValidator {
    // MARK: - Properties
    private let config: ResponseStatusCodeValidatorConfig
    
    // MARK: - Init
    init(config: ResponseStatusCodeValidatorConfig) {
        self.config = config
    }
    
    // MARK: - Public
    func checkIsStatusCodeValid(inResponse response: HTTPURLResponse) throws(ResponseStatusCodeValidatorError) {
        let statusCode = response.statusCode
        
        guard config.validStatusCodes.contains(statusCode) else {
            throw .invalidStatusCode(statusCode)
        }
    }
}

extension ResponseStatusCodeValidatorConfig {
    static let `default` = ResponseStatusCodeValidatorConfig(validStatusCodes: [200, 201])
}
