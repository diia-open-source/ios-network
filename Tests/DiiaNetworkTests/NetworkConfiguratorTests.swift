

import XCTest
import Alamofire
@testable import DiiaNetwork

final class NetworkConfigurationTests: XCTestCase {
    
    func test_makeSession() {
        // Arrange
        let sut = createSut()
        
        // Act
        sut.set(interceptor: RequestInterceptorMock())
        sut.set(serverTrustPolicies: ["test": DefaultTrustEvaluator()])
        let session = sut.session
        
        // Assert
        XCTAssertNotNil(session.interceptor)
        XCTAssertNotNil(session.serverTrustManager)
    }
    
    func test_sessionWithoutInterceptor() {
        // Arrange
        let sut = createSut()
        
        // Act
        let session = sut.sessionWithoutInterceptor
        
        // Assert
        XCTAssertNil(session.interceptor)
    }
    
    func test_insecureSession() {
        // Arrange
        let sut = createSut()
        let host = "example.com"
        
        // Act
        let session = sut.insecureSession(with: host)
        
        // Assert
        XCTAssertNotNil(session.serverTrustManager)
    }
    
    func test_otherDependencies_setCorrectly() {
        // Arrange
        let sut = createSut()
        
        // Act
        sut.set(logging: true)
        sut.set(httpStatusCodeHandler: HTTPStatusCodeHandlerMock())
        sut.set(jsonDecoderConfig: JSONDecoderConfigMock())
        sut.set(responseErrorHandler: ResponseErrorHandlerMock())
        sut.set(analyticsHandler: AnalyticsNetworkHandlerMock())
        
        // Assert
        XCTAssertTrue(sut.logging)
        XCTAssertNotNil(sut.httpStatusCodeHandler)
        XCTAssertNotNil(sut.jsonDecoderConfig)
        XCTAssertNotNil(sut.responseErrorHandler)
        XCTAssertNotNil(sut.analyticsHandler)
    }
}

private extension NetworkConfigurationTests {
    func createSut() -> NetworkConfiguration {
        return .init()
    }
}
