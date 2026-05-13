
import Alamofire
import Foundation

final class RequestManager {
    // MARK: - Static
    static func compose() -> RequestManager {
        let configuration = NetworkConfiguration.default
        
        let logger = configuration.logger
        let nSErrorAdapter = NSErrorAdapter()
        let responseProvider = ResponseProviderImpl()
        let reachabilityChecker = ReachabilityCheckerImpl()
        let analyticsCollector = configuration.analyticsHandler
        let responseErrorHandler = configuration.responseErrorHandler
        let statusCodeValidator = ResponseStatusCodeValidatorImpl(config: .default)
        let responseMapper = ResponseMapperImpl(decoder: configuration.jsonDecoderConfig)
        let responseErrorAdapter = ResponseErrorAdapterImpl(domainErrorDetector: nSErrorAdapter)
        
        return RequestManager(
            logger: logger,
            responseMapper: responseMapper,
            responseProvider: responseProvider,
            reachabilityChecker: reachabilityChecker,
            responseErrorAdapter: responseErrorAdapter,
            responseErrorHandler: responseErrorHandler,
            analyticsCollector: analyticsCollector,
            statusCodeValidator: statusCodeValidator
        )
    }
    
    // MARK: - Properties
    private let logger: NetworkLoggerProtocol?
    private let responseErrorHandler: ResponseErrorHandler?
    private let analyticsCollector: AnalyticsNetworkHandler?
    
    private let responseMapper: ResponseMapper
    private let responseProvider: ResponseProvider
    private let reachabilityChecker: ReachabilityChecker
    private let responseErrorAdapter: ResponseErrorAdapter
    private let statusCodeValidator: ResponseStatusCodeValidator

    // MARK: - Init
    init(
        logger: NetworkLoggerProtocol?,
        responseMapper: ResponseMapper,
        responseProvider: ResponseProvider,
        reachabilityChecker: ReachabilityChecker,
        responseErrorAdapter: ResponseErrorAdapter,
        responseErrorHandler: ResponseErrorHandler?,
        analyticsCollector: AnalyticsNetworkHandler?,
        statusCodeValidator: ResponseStatusCodeValidator
    ) {
        self.logger = logger
        self.responseMapper = responseMapper
        self.responseProvider = responseProvider
        self.analyticsCollector = analyticsCollector
        self.statusCodeValidator = statusCodeValidator
        self.reachabilityChecker = reachabilityChecker
        self.responseErrorHandler = responseErrorHandler
        self.responseErrorAdapter = responseErrorAdapter
    }
    
    // MARK: - Public
    func perform<U: Decodable>(_ dataRequest: DataRequest) async throws(NetworkError) -> U {
        do {
            try reachabilityChecker.checkIsReachable()
            try Task.checkCancellation()

            sendAnalytics(eventType: .networkRequestInit, for: dataRequest)
            try Task.checkCancellation()

            dataRequest.resume()
            try Task.checkCancellation()

            let response = try await responseProvider.response(for: dataRequest)
            log(uRLResponse: response.uRLResponse, responseData: response.data)
            try Task.checkCancellation()

            try statusCodeValidator.checkIsStatusCodeValid(inResponse: response.uRLResponse)
            try Task.checkCancellation()

            let value: U = try responseMapper.map(data: response.data)
            sendAnalytics(eventType: .networkRequestSuccess, for: dataRequest)
            try Task.checkCancellation()

            return value
        } catch {
            let networkError = responseErrorAdapter.adaptError(error)
            
            switch networkError {
            case .cancelled:
                break
            default:
                responseErrorHandler?.handleError(error: networkError as NSError)
                sendAnalytics(eventType: .networkRequestFailed, for: dataRequest)
            }
            
            logError(networkError)
            
            throw networkError
        }
    }
    
    // MARK: - Private -
    private func log(uRLResponse: HTTPURLResponse?, responseData: Data?) {
        guard let logger else { return }
        
        if let uRLResponse {
            logger.log("RESPONSE: \(uRLResponse.url?.absoluteString ?? "")")
            logger.log("HEADERS: \(uRLResponse.allHeaderFields as? [String: String] ?? [:])")
        }

        guard let responseData else {
            logger.log("Response data is nil")
            return
        }

        if let value = try? JSONSerialization.jsonObject(with: responseData),
           let rawData = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted]),
           let jsonString = String(data: rawData, encoding: String.Encoding.utf8) {
            logger.log("Response data: \(jsonString)")
        } else {
            let bytes = ByteCountFormatter().string(fromByteCount: Int64(responseData.count))
            logger.log("Empty response or incorrect data format. Data size: \(bytes)")
        }
    }
    
    private func logError(_ error: Error) {
        logger?.logError(error)
    }
    
    private func sendAnalytics(eventType: AnalyticsEventType, for dataRequest: DataRequest) {
        guard let analyticsCollector else { return }
        
        guard let service = dataRequest.convertible as? CommonService else {
            fatalError("URLRequestConvertible must conform to CommonService")
        }
        
        switch eventType {
        case .networkRequestInit:
            analyticsCollector.trackNetworkInitEvent(action: service.analyticsName)

        case .networkRequestSuccess:
            analyticsCollector
                .trackNetworkResultEvent(
                    action: service.analyticsName,
                    result: AnalyticsNetworkResult.success.rawValue,
                    extraData: service.analyticsAdditionalParameters
                )
        case .networkRequestFailed:
            analyticsCollector
                .trackNetworkResultEvent(
                    action: service.analyticsName,
                    result: AnalyticsNetworkResult.fail.rawValue,
                    extraData: service.analyticsAdditionalParameters
                )
        }
    }
}

private enum AnalyticsEventType {
    case networkRequestInit
    case networkRequestSuccess
    case networkRequestFailed
}
