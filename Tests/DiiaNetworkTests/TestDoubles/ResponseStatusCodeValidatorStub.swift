
import Foundation
@testable import DiiaNetwork

final class ResponseStatusCodeValidatorStub: ResponseStatusCodeValidator {
    private(set) var callsCount = 0
    
    var onValidationAsked: ((RequestExecutionSteps) -> Void)?
    
    func checkIsStatusCodeValid(inResponse response: HTTPURLResponse) throws(ResponseStatusCodeValidatorError) {
        callsCount += 1
        onValidationAsked?(.statusCodeValidation)
    }
}
