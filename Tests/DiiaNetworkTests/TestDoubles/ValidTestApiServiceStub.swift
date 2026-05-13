
import Foundation
@testable import DiiaNetwork

final class ValidTestApiServiceStub: CommonService {
    static let domain = "dummyjson.com"

    let method: HTTPMethod = .get
    let path: String = "http/200"
    let parameters: [String: Any]? = nil
    let headers: [String : String]? = nil
    let timeoutInterval: TimeInterval = 0.5
    let host: String = "https://\(domain)"
    let analyticsName: String = ""
    let analyticsAdditionalParameters: String? = nil
}
