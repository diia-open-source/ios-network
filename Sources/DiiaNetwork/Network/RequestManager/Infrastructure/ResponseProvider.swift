
import Alamofire
import Foundation

protocol ResponseProvider {
    func response(for dataRequest: DataRequest) async throws(ResponseProviderError) -> NetworkRequestResponse
}

enum ResponseProviderError: Error {
    case responseDoesNotExist
    case dataFetchingError(Error)
}

final class NetworkRequestResponse {
    // MARK: - Properties
    let data: Data
    let uRLResponse: HTTPURLResponse
    
    // MARK: - Init
    init(data: Data, uRLResponse: HTTPURLResponse) {
        self.data = data
        self.uRLResponse = uRLResponse
    }
}

final class ResponseProviderImpl: ResponseProvider {
    private let allowedEmptyResponseCodes = Set(200..<300)

    // MARK: - Public
    func response(for dataRequest: DataRequest) async throws(ResponseProviderError) -> NetworkRequestResponse {
        let data = try await fetchData(from: dataRequest)
        
        guard let uRLResponse = dataRequest.response else {
            throw ResponseProviderError.responseDoesNotExist
        }
        
        let networkRequestResponse = NetworkRequestResponse(
            data: data,
            uRLResponse: uRLResponse
        )
        
        return networkRequestResponse
    }
    
    // MARK: - Private -
    private func fetchData(from dataRequest: DataRequest) async throws(ResponseProviderError) -> Data {
        do {
            let dataTask = dataRequest.serializingData(emptyResponseCodes: allowedEmptyResponseCodes)
            let data = try await dataTask.value
            
            return data
        } catch {
            throw .dataFetchingError(error)
        }
    }
}
