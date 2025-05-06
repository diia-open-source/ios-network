
import ReactiveKit
import Alamofire

public protocol ErrorHandler: AnyObject {
    func handleError(_ error: NetworkError)
}

open class ApiClient<T: CommonService> {
    open var sessionManager: Alamofire.Session = {
        NetworkConfiguration.default.session
    }()

    public init() {}

    public func request<U: Decodable>(_ service: T, keyPath: String? = nil) -> Signal<U, NetworkError> {
        return sessionManager.request(service).objectSignal(keyPath: keyPath)
    }

    public func request<U: Decodable & ExpressibleByNilLiteral>(_ service: T, keyPath: String? = nil) -> Signal<U, NetworkError> {
        return sessionManager.request(service).objectSignal(keyPath: keyPath)
    }

    public func loadRequest<U: Decodable>(_ service: T,
                                          progressHandler: ProgressHandler? = nil,
                                          errorHandler: ErrorHandler? = nil,
                                          keyPath: String? = nil) -> SafeSignal<U> {
        weak var progressHandler = progressHandler
        weak var errorHandler = errorHandler

        let signal: Signal<U, NetworkError> = sessionManager.request(service).objectSignal(keyPath: keyPath)

        return signal
            .progress(start: { progressHandler?.showProgress() },
                      end: { progressHandler?.hideProgress() })
            .processError(handler: { error in errorHandler?.handleError(error) })
    }
}
