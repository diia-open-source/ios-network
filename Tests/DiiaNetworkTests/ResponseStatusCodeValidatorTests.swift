
import Testing
import Foundation
@testable import DiiaNetwork

final class ResponseStatusCodeValidatorTests: Test {
    @Test("If validation passed, then no error is thrown")
    func validStatusCodeApproved() throws {
        let response = try #require(makeResponse(statusCode: 400))
        try makeSUT(validCodes: [400]).checkIsStatusCodeValid(inResponse: response)
    }
    
    @Test("If validation does not passed, then error is thrown")
    func validStatusCodeRejected() throws {
        let response = try #require(makeResponse(statusCode: 500))
        
        #expect(throws: anyErrorType) {
            try makeSUT(validCodes: [200]).checkIsStatusCodeValid(inResponse: response)
        }
    }
    
    @Test("If validation does not passed, then correct error is thrown")
    func thrownErrorIsCorrect() throws {
        let response = try #require(makeResponse(statusCode: 500))
        
        #expect(throws: ResponseStatusCodeValidatorError.invalidStatusCode(500)) {
            try makeSUT(validCodes: [200]).checkIsStatusCodeValid(inResponse: response)
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(
        validCodes: [Int],
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ResponseStatusCodeValidator {
        let validator = ResponseStatusCodeValidatorImpl(
            config: ResponseStatusCodeValidatorConfig(
                validStatusCodes: validCodes
            )
        )
        trackForMemoryLeaks(validator, file: file, line: line)
        return validator
    }
    
    private func makeResponse(statusCode: Int) -> HTTPURLResponse? {
        return HTTPURLResponse(
            url: URL(fileURLWithPath: ""),
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
    }
}

extension ResponseStatusCodeValidatorError: @retroactive Equatable {
    public static func == (lhs: ResponseStatusCodeValidatorError, rhs: ResponseStatusCodeValidatorError) -> Bool {
        switch lhs {
        case .invalidStatusCode(let lhsCode):
            switch rhs {
            case .invalidStatusCode(let rhsCode):
                return lhsCode == rhsCode
            }
        }
    }
}
