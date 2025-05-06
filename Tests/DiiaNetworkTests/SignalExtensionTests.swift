
import XCTest
import ReactiveKit
@testable import DiiaNetwork

final class SignalExtensionTests: XCTestCase {
    func test_progress_completedSuccessfully() {
        // Arrange
        let signal = Signal<String, Error> { observer in
            observer.receive("test1")
            observer.receive("test2")
            observer.receive(completion: .finished)
            
            return BlockDisposable {}
        }
        
        var startCalled = false
        var endCalled = false
        
        // Act
        let progressSignal = signal.progress(
            start: {
                startCalled = true
                XCTAssertFalse(endCalled, "End shouldn't be called before start")
            },
            end: {
                endCalled = true
                XCTAssertTrue(startCalled, "Start should be called before end")
            }
        )
        
        var receivedValues: [String] = []
        var isCompleted: Bool = false
        let expectation = self.expectation(description: "Signal completion")
        
        let disposable = progressSignal.observe { event in
            switch event {
            case .next(let value):
                receivedValues.append(value)
            case .completed:
                isCompleted.toggle()
                expectation.fulfill()
            case .failed:
                XCTFail("Unexpected error")
            }
        }
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(receivedValues, ["test1", "test2"])
        XCTAssertTrue(isCompleted)
        XCTAssertTrue(startCalled)
        XCTAssertTrue(endCalled)
        
        disposable.dispose()
    }
    
    func test_progress_failure() {
        // Arrange
        let signal = Signal<Int, Error> { observer in
            observer.receive(completion: .failure(NetworkError.noData))
            return BlockDisposable {}
        }
        
        var startCalled = false
        var endCalled = false
        
        // Act
        let progressSignal = signal.progress(
            start: {
                startCalled = true
                XCTAssertFalse(endCalled, "End shouldn't be called before start")
            },
            end: {
                endCalled = true
                XCTAssertTrue(startCalled, "Start should be called before end")
            }
        )
        
        var isCompleted: Bool = false
        let expectation = self.expectation(description: "Signal failure")
        
        let disposable = progressSignal.observe { event in
            switch event {
            case .next:
                break
            case .completed:
                isCompleted.toggle()
                expectation.fulfill()
            case .failed(let error):
                XCTAssertEqual(error as? NetworkError, .noData)
                expectation.fulfill()
            }
        }
        
        // Assert
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(isCompleted) // No completion event for failed case
        XCTAssertTrue(startCalled)
        XCTAssertTrue(endCalled)
        
        disposable.dispose()
    }
    
    func test_processError_forCompletedSuccessfullyEvent() {
        // Arrange
        let safeSignal = Signal<String, Error> { observer in
            observer.receive("test1")
            observer.receive(completion: .finished)
            return BlockDisposable {}
        }
        
        // Act
        let processedSignal = safeSignal.processError { error in
            XCTFail("Unexpected error: \(error)")
        }
        
        var receivedValue: String?
        var completionReceived = false
        _ = processedSignal.observe { event in
            if case .next(let value) = event {
                receivedValue = value
            } else if case .completed = event {
                completionReceived = true
            }
        }
        
        // Assert
        XCTAssertEqual(receivedValue, "test1")
        XCTAssertTrue(completionReceived)
    }
    
    func test_processError_forFailedEvent() {
        // Arrange
        let expectation = self.expectation(description: "Error handler called")
        let errorToBeEmitted = NetworkError.noData
        let safeSignal = Signal<String, Error> { observer in
            observer.receive(completion: .failure(errorToBeEmitted))
            return BlockDisposable {}
        }
        
        // Act & Assert
        let disposable = safeSignal.processError { error in
            // Assert on the error if needed
            XCTAssertEqual(error as? NetworkError, errorToBeEmitted)
            expectation.fulfill()
        }.observe { _ in }
        
        waitForExpectations(timeout: 1.0, handler: nil)
        disposable.dispose()
    }
}
