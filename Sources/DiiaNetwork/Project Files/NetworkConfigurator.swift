import Foundation
import Alamofire

public class NetworkConfiguration {
    public static let `default`: NetworkConfiguration = NetworkConfiguration()
    public private(set) var logging: Bool = false
    public private(set) var httpStatusCodeHandler: HTTPStatusCodeHandler?
    public private(set) var interceptor: RequestInterceptor?
    public private(set) var serverTrustPolicies: [String: ServerTrustEvaluating] = [:]
    public private(set) var jsonDecoderConfig: JSONDecoderConfigProtocol?
    
    public private(set) var responseErrorHandler: ResponseErrorHandler?
    public private(set) var analyticsHandler: AnalyticsNetworkHandler?
    
    private let urlSessionConfiguration = URLSessionConfiguration.ephemeral
    
    public private(set) lazy var session: Session = {
        return makeSession()
    }()
    
    public private(set) lazy var sessionWithoutInterceptor: Session = {
        return makeSessionWithoutInterceptor()
    }()
    
    public func insecureSession(with host: String) -> Session {
        let trustManager = ServerTrustManager(allHostsMustBeEvaluated: false,
                                              evaluators: [host: DisabledTrustEvaluator()])
        return Session(configuration: urlSessionConfiguration,
                       startRequestsImmediately: false,
                       serverTrustManager: trustManager)
    }
    
    public func set(logging: Bool) {
        self.logging = logging
    }
    
    public func set(httpStatusCodeHandler: HTTPStatusCodeHandler?) {
        self.httpStatusCodeHandler = httpStatusCodeHandler
    }
    
    public func set(interceptor: RequestInterceptor?) {
        self.interceptor = interceptor
        initSessions()
    }
    
    public func set(serverTrustPolicies: [String: ServerTrustEvaluating]) {
        self.serverTrustPolicies = serverTrustPolicies
        initSessions()
    }
    
    public func set(jsonDecoderConfig: JSONDecoderConfigProtocol?) {
        self.jsonDecoderConfig = jsonDecoderConfig
    }
    
    public func set(responseErrorHandler: ResponseErrorHandler?) {
        self.responseErrorHandler = responseErrorHandler
    }
    
    public func set(analyticsHandler: AnalyticsNetworkHandler?) {
        self.analyticsHandler = analyticsHandler
    }
    
    // MARK: - Private
    private func initSessions() {
        session = makeSession()
        sessionWithoutInterceptor = makeSessionWithoutInterceptor()
    }
    
    private func makeSession() -> Session {
        return Session(configuration: urlSessionConfiguration,
                       startRequestsImmediately: false,
                       interceptor: interceptor,
                       serverTrustManager: ServerTrustManager(evaluators: serverTrustPolicies))
    }
    
    private func makeSessionWithoutInterceptor() -> Session {
        return Session(configuration: urlSessionConfiguration,
                       startRequestsImmediately: false,
                       interceptor: nil,
                       serverTrustManager: ServerTrustManager(evaluators: serverTrustPolicies))
    }
}
