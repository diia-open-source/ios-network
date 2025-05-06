
import Foundation
import Alamofire

public class NetworkResponseHandler<GeneralModel: GeneralNetworkResponse> {
    private let nsURLErrorHandler: NSErrorHandler
    private let decoderConfig: JSONDecoderConfigProtocol?
    private let httpStatusCodeOk = 200
    private let httpStatusCodeCreated = 201

    private var httpStatusCodeHandler: HTTPStatusCodeHandler? {
        return NetworkConfiguration.default.httpStatusCodeHandler
    }
    
    private var responseErrorHandler: ResponseErrorHandler? {
        return NetworkConfiguration.default.responseErrorHandler
    }
    
    var logger: NetworkLoggerProtocol? {
        return NetworkConfiguration.default.logger
    }
    
    public init(nsURLErrorHandler: NSErrorHandler = NSErrorAdapter(),
                decoderConfig: JSONDecoderConfigProtocol? = nil) {
        self.nsURLErrorHandler = nsURLErrorHandler

        self.decoderConfig = decoderConfig ?? NetworkConfiguration.default.jsonDecoderConfig
    }
    
    func parseGeneralModel(from jsonObject: Data?) throws -> GeneralModel {
        guard let data = jsonObject else {
            throw NetworkError.noData
        }
        return try JSONDecoder().decode(GeneralModel.self, from: data)
    }
    
    func parse<T: Decodable>(from jsonObject: Data) throws -> T {
        return try (decoderConfig?.jsonDecoder() ?? JSONDecoder()).decode(T.self, from: jsonObject)
    }
    
    func log(response: HTTPURLResponse?, error: Error?, responseData: Data?) {
        if let logger = logger {
            if let response = response {
                logger.log("RESPONSE: \(response.url?.absoluteString ?? "")")
                logger.log("HEADERS: \(response.allHeaderFields as? [String: String] ?? [:])")
            }
            if let error = error {
                logger.log("Error description: \(error.localizedDescription)")
            }
            
            if let responseData = responseData,
                let value = try? JSONSerialization.jsonObject(with: responseData),
                let rawData = try? JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted]),
                let jsonString = String(data: rawData, encoding: String.Encoding.utf8) {
                logger.log("Response data: \(jsonString)")
            }
        }
    }
    
    func validateHTTPStatusCodeSuccess(statusCode: Int?, responseError: NetworkError?) throws {
        if let statusCode = statusCode, statusCode != httpStatusCodeOk && statusCode != httpStatusCodeCreated {
            let descr = HTTPURLResponse.localizedString(forStatusCode: statusCode).capitalized
            throw NetworkError.wrongStatusCode(descr, statusCode, responseError)
        }
    }
    
    // Error management: https://diia.atlassian.net/browse/DIIA-290
    func processResponse(_ response: HTTPURLResponse?,
                         error: Error?,
                         responseData: Data?,
                         keyPath: String?) throws -> Data /*GeneralNetworkResponse*/ {
        do {
            log(response: response, error: error, responseData: responseData)
            
            // Response handling if possible
            if let responseErrorHandler = responseErrorHandler,
               let code = response?.statusCode,
               code >= 300,
               let data = responseData,
               let url = response?.url?.absoluteString,
               let error = String(data: data, encoding: .utf8) {
                let customError = NSError(domain: url,
                                          code: code,
                                          userInfo: ["message": error, "url": url])
                responseErrorHandler.handleError(error: customError)
            }
            
            // Error handling
            try nsURLErrorHandler.validateForNSError(error: error)
            
            // Status code handling
            httpStatusCodeHandler?.handleStatusCode(statusCode: response?.statusCode ?? 200)
            
            try validateHTTPStatusCodeSuccess(statusCode: response?.statusCode, responseError: nil)
            
            guard var data = responseData else { throw NetworkError.noData }
            if let keyPath = keyPath {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                if let dict = jsonData as? [String: Any],
                   let keyPathData = dict[keyPath] {
                    data = try JSONSerialization.data(withJSONObject: keyPathData, options: [])
                } else {
                    throw NetworkError.noData
                }
            }
            return data
        } catch let error {
            throw error
        }
    }
    
    func successHandlingResponse<T: Decodable>(_ response: HTTPURLResponse?,
                                               error: Error?,
                                               responseData: Data?,
                                               keyPath: String?) throws -> T {
        
        let generalResponse = try processResponse(response,
                                                  error: error,
                                                  responseData: responseData,
                                                  keyPath: keyPath)
        
        return try parse(from: generalResponse)
    }
    
    func failedHandlingResponse(error: Error) {
        if let logger = logger {
            logger.log(error)
        }
    }
}
