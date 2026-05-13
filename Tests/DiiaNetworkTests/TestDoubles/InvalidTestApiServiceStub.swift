
import Foundation
@testable import DiiaNetwork

final class InvalidTestApiServiceStub: CommonService {
    let method: HTTPMethod = .get
    let path: String = ""
    let parameters: [String: Any]? = nil
    let headers: [String : String]? = nil
    let timeoutInterval: TimeInterval = 0.5
    let host: String = ""
    let analyticsName: String = ""
    let analyticsAdditionalParameters: String? = nil
}
