
import Foundation
import Alamofire
import ReactiveKit

public extension DataRequest {
    private var analyticsHandler: AnalyticsNetworkHandler? {
        return NetworkConfiguration.default.analyticsHandler
    }
    
    func objectSignal<T: Decodable>(keyPath: String? = nil) -> Signal<T, NetworkError> {
        return objectSignal(keyPath: keyPath, responseHandler: NetworkResponseHandler<GeneralResponse>())
    }

    func objectSignal<T: Decodable & ExpressibleByNilLiteral>(keyPath: String? = nil) -> Signal<T, NetworkError> {
        return objectSignal(keyPath: keyPath, responseHandler: NetworkResponseHandler<GeneralResponse>())
    }

    func objectSignal<T: Decodable, GeneralModel: GeneralNetworkResponse>
        (keyPath: String? = nil,
         responseHandler: NetworkResponseHandler<GeneralModel>) -> Signal<T, NetworkError> {
        return createObjectSignal(keyPath: keyPath, responseHandler: responseHandler)
    }

    func objectSignal<T: Decodable & ExpressibleByNilLiteral, GeneralModel: GeneralNetworkResponse>
        (keyPath: String? = nil,
         responseHandler: NetworkResponseHandler<GeneralModel>) -> Signal<T, NetworkError> {
        return flatMapNilValue(signal: createObjectSignal(keyPath: keyPath, responseHandler: responseHandler))
    }

    private func flatMapNilValue<U: Decodable>(signal: Signal<U, NetworkError>) -> Signal<U, NetworkError> where U: ExpressibleByNilLiteral {
        return signal.flatMapError { error -> Signal<U, NetworkError> in
            if error == NetworkError.noData {
                return Signal(just: nil)
            } else {
                return Signal.failed(error)
            }
        }
    }
    
    func createObjectSignal<T: Decodable, GeneralModel: GeneralNetworkResponse>
        (keyPath: String? = nil,
         responseHandler: NetworkResponseHandler<GeneralModel>) -> Signal<T, NetworkError> {
        if !(Alamofire.NetworkReachabilityManager.default?.isReachable == true) {
            return .init(result: .failure(NetworkError.noInternet))
        }
        
        return Signal { observer in
            let validatedRequest = self.addUnautorizeValidation()
            
            let service = self.convertible as? CommonService
            self.analyticsHandler?.trackNetworkInitEvent(action: service?.analyticsName ?? "")
            
            let request = validatedRequest.responseObject(keyPath: keyPath, responseHandler: responseHandler) { (response: AFDataResponse<T>) in
                switch response.result {
                case .success(let value):
                    self.analyticsHandler?.trackNetworkResultEvent(action: service?.analyticsName ?? "",
                                                                   result: AnalyticsNetworkResult.success.rawValue,
                                                                   extraData: service?.analyticsAdditionalParameters ?? "")
                    observer.receive(lastElement: value)
                case .failure(let error):
                    self.analyticsHandler?.trackNetworkResultEvent(action: service?.analyticsName ?? "",
                                                                   result: AnalyticsNetworkResult.fail.rawValue,
                                                                   extraData: error.errorDescription)
                    let error = error.underlyingError as? NetworkError ?? NetworkError.anotherError(error.localizedDescription, error)
                    observer.receive(completion: .failure(error))
                }
            }
            
            request.resume()
            
            return BlockDisposable {
                request.cancel()
            }
        }
    }

    func addUnautorizeValidation() -> DataRequest {
        return self.validate { _, response, _ -> Request.ValidationResult in
            if response.statusCode == 401 {
                let descr = HTTPURLResponse.localizedString(forStatusCode: response.statusCode).capitalized
                return .failure(NetworkError.wrongStatusCode(descr, response.statusCode, nil))
            } else {
                return .success(())
            }
        }
    }
}
