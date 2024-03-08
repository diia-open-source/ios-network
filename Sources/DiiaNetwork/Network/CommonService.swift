import Alamofire
import Foundation

public protocol CommonService: URLRequestConvertible {
    
    typealias HTTPMethod = Alamofire.HTTPMethod
    /**
     Method for service
     */
    var method: HTTPMethod { get }
    
    /**
     Path for service
     */
    var path: String { get }
    
    /**
     Parameters for service
     */
    var parameters: [String: Any]? { get }
    
    /**
     Headers for service
     */
    var headers: [String: String]? { get }
    
    /**
     Headers for service
     */
    var timeoutInterval: TimeInterval { get }
    
    /**
     Path for service
     */
    var host: String { get }
    
    /**
     Use for tracking network event in analytics
     */
    var analyticsName: String { get }
    
    /**
     Used for sending additional parameters during network event tracking in analytics
     */
    var analyticsAdditionalParameters: String? { get }
}

public extension CommonService {
    
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let config = NetworkConfiguration.default
        guard let url = URL(string: host)?.appendingPathComponent(path) else {
            throw NetworkError.badUrl
        }
        var mutableURLRequest = URLRequest(url: url)

        mutableURLRequest.httpMethod = method.rawValue
        mutableURLRequest.timeoutInterval = timeoutInterval
        if let headers = headers {
            for (key, value) in headers {
                mutableURLRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let url = mutableURLRequest.url, config.logging {
            print("REQUEST: \(method.rawValue) \(url)")
            print("Request headers: \(mutableURLRequest.allHTTPHeaderFields ?? [:])")
            if let parameters = parameters {
               print("Request data: \(parameters)")
            }
        }
        
        if let parameters = parameters {
            return try encodingForRequest().encode(mutableURLRequest, with: parameters)
        } else {
            return mutableURLRequest
        }
    }

    private func encodingForRequest() -> ParameterEncoding {
        switch method {
        case .post, .put, .delete, .patch:
            return Alamofire.JSONEncoding.default as ParameterEncoding
        case .get:
            return Alamofire.URLEncoding.default as ParameterEncoding
        default:
            return Alamofire.URLEncoding.default as ParameterEncoding
        }
    }
}
