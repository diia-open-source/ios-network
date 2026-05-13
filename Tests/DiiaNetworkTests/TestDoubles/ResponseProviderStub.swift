
import Alamofire
import Foundation
@testable import DiiaNetwork

final class ResponseProviderStub: ResponseProvider {
    private var responseData: Data
    private(set) var responseRequestsCount = 0
    
    var onResponseRequested: ((RequestExecutionSteps) -> Void)?
    
    var errorToThrow: ResponseProviderError?

    init(responseData: Data) {
        self.responseData = responseData
    }
    
    func response(for dataRequest: DataRequest) async throws(ResponseProviderError) -> NetworkRequestResponse {
        responseRequestsCount += 1
        
        let urlResponse = HTTPURLResponse(
            url: URL(fileURLWithPath: ""),
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        
        onResponseRequested?(.responseFetching)
        
        if let errorToThrow {
            throw errorToThrow
        } else {
            return NetworkRequestResponse(
                data: responseData,
                uRLResponse: urlResponse
            )
        }        
    }
}
