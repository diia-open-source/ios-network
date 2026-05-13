
import XCTest
import Testing

class Test: XCTestCase {
    let anyErrorType = (any Error).self

    func trackForMemoryLeaks(_ instance: AnyObject,
                             file: StaticString = #filePath,
                             line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.",
                         file: file,
                         line: line)
        }
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject,
                             _ sourceLocation: SourceLocation = #_sourceLocation) {
        addTeardownBlock { [weak instance] in
            #expect(
                instance == nil,
                "Instance should have been deallocated. Potential memory leak.",
                sourceLocation: sourceLocation
            )
        }
    }
}
