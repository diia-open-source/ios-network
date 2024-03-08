import Foundation
import DiiaNetwork

class ApiServiceStub: CommonService {
    var method: HTTPMethod = .get
    
    var path: String = ""
    
    var parameters: [String : Any]? = nil
    
    var headers: [String : String]? = nil
    
    var timeoutInterval: TimeInterval = 0.5
    
    var host: String = ""
    
    var analyticsName: String = ""
    
    var analyticsAdditionalParameters: String? = nil
}
