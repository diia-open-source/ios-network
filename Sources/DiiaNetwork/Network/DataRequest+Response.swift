import Foundation
import Alamofire

public extension DataRequest {
    func responseObject<T: Decodable, GeneralModel: GeneralNetworkResponse>
        (keyPath: String? = nil,
         responseHandler: NetworkResponseHandler<GeneralModel>,
         completion: @escaping (AFDataResponse<T>) -> Void) -> Self {
        let serializer = NetworkSerializer<T, GeneralModel>(keyPath: keyPath, responseHandler: responseHandler)
        
        return response(responseSerializer: serializer, completionHandler: completion)
    }
    
    func responseObject<T: Decodable>(keyPath: String? = nil,
                                      completion: @escaping (AFDataResponse<T>) -> Void) -> Self {
        return responseObject(keyPath: keyPath,
                              responseHandler: NetworkResponseHandler<GeneralResponse>(),
                              completion: completion)
    }
}
