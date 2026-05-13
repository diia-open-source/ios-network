
import Alamofire
import Foundation
import ReactiveKit

public protocol ErrorHandler: AnyObject {
    func handleError(_ error: NetworkError)
}

open class ApiClient<T: CommonService> {
    open var sessionManager: Alamofire.Session = {
        NetworkConfiguration.default.session
    }()
    
    private var tasksBag: CancelationBag
    private let requestManager: RequestManager
    
    public init() {
        self.tasksBag = CancelationBag()
        self.requestManager = RequestManager.compose()
    }
    
    // MARK: - Reactive APIs
    // MARK: Will be removed soon❗️
    
    /// Performs a network request and returns a signal with a decoded response.
    ///
    /// - Parameters:
    ///   - service: The network service to request.
    ///   - keyPath: Optional key path for nested JSON decoding.
    /// - Returns: A signal that emits a decoded object or a `NetworkError`.
    ///
    /// - Warning: This method will be deprecated soon. Prefer using:
    ///   - callback variant: `request(_:keyPath:completion:)`
    ///   - async/await variant: `request(_:keyPath:) async throws`
    public func request<U: Decodable>(_ service: T, keyPath: String? = nil) -> Signal<U, NetworkError> {
        return sessionManager.request(service).objectSignal(keyPath: keyPath)
    }
    
    /// Performs a network request and returns a signal with a decoded and nil literal responses.
    ///
    /// - Parameters:
    ///   - service: The network service to request.
    ///   - keyPath: Optional key path for nested JSON decoding.
    /// - Returns: A signal that emits a decoded object or a `NetworkError`.
    ///
    /// - Warning: This method will be deprecated soon. Prefer using:
    ///   - callback variant: `request(_:keyPath:completion:)`
    ///   - async/await variant: `request(_:keyPath:) async throws`
    public func request<U: Decodable & ExpressibleByNilLiteral>(_ service: T, keyPath: String? = nil) -> Signal<U, NetworkError> {
        return sessionManager.request(service).objectSignal(keyPath: keyPath)
    }
    
    /// Performs a network request with progress and error handling, and returns a safe signal with a decoded response.
    ///
    /// - Parameters:
    ///   - service: The network service to request.
    ///   - progressHandler: An optional handler for showing and hiding a progress indicator during the request.
    ///   - errorHandler: An optional handler for processing network errors.
    ///   - keyPath: Optional key path for nested JSON decoding.
    /// - Returns: A `SafeSignal` that emits a decoded object. Errors are forwarded to `errorHandler`.
    ///
    /// - Warning: This method will be deprecated soon. Prefer using:
    ///   - callback variant: `request(_:progressHandler:errorHandler:keyPath:completion:)`
    ///   - async/await variant: `request(_:keyPath:) async throws`
    public func request<U: Decodable>(_ service: T,
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
    
    // MARK: - Async APIs
    public func request<U: Decodable>(_ service: T) async throws(NetworkError) -> U {
        let dataRequest = sessionManager.request(service)
        let value: U = try await requestManager.perform(dataRequest)
        
        return value
    }
    
    // MARK: - Callback APIs
    public func request<U: Decodable>(_ service: T,
                                      onSuccess: @escaping (U) -> Void,
                                      onFailure: @escaping (NetworkError) -> Void) {
        Task.detached { [sessionManager, requestManager] in
            do throws(NetworkError) {
                let dataRequest = sessionManager.request(service)
                let value: U = try await requestManager.perform(dataRequest)

                await MainActor.run {
                    onSuccess(value)
                }
            } catch {
                await MainActor.run {
                    onFailure(error)
                }
            }
        }
        .dispose(in: tasksBag)
    }

    public func request<U: Decodable>(_ service: T,
                                      completion: @escaping (Result<U, NetworkError>) -> Void) {
        Task.detached { [sessionManager, requestManager] in
            do throws(NetworkError) {
                let dataRequest = sessionManager.request(service)
                let value: U = try await requestManager.perform(dataRequest)

                await MainActor.run {
                    completion(.success(value))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
        .dispose(in: tasksBag)
    }
    
    // MARK: - Handlers APIs
    public func request<U: Decodable>(_ service: T,
                                      progressHandler: ProgressHandler? = nil,
                                      errorHandler: ErrorHandler? = nil,
                                      callback: @escaping (U) -> Void) {
        weak var errorHandler = errorHandler
        weak var progressHandler = progressHandler
        
        Task.detached { [sessionManager, requestManager] in
            progressHandler?.showProgress()
            
            do throws(NetworkError) {
                let dataRequest = sessionManager.request(service)
                let value: U = try await requestManager.perform(dataRequest)

                await MainActor.run {
                    progressHandler?.hideProgress()
                    callback(value)
                }
            } catch {
                await MainActor.run {
                    progressHandler?.hideProgress()
                    errorHandler?.handleError(error)
                }
            }
        }
        .dispose(in: tasksBag)
    }
}
