
import Foundation
import Alamofire

public struct NetworkSerializer<T: Decodable, GeneralModel: GeneralNetworkResponse>: DataResponseSerializerProtocol {
    public typealias SerializedObject = T
    let keyPath: String?
    let responseHandler: NetworkResponseHandler<GeneralModel>
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        do {
            return try responseHandler.successHandlingResponse(response, error: error, responseData: data, keyPath: keyPath)
        } catch let error {
            responseHandler.failedHandlingResponse(error: error)
            throw error
        }
    }
}
