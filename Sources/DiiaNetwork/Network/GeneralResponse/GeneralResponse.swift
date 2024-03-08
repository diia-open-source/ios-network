import Foundation

public struct GeneralResponse: GeneralNetworkResponse {
    /**
     Error description
     */
    public let error: NetworkError?
    
    /**
     Data
     */
    public let data: Any?

    enum CommonKeys: String, CodingKey {
        case data
        case error
    }
    
    public init(from decoder: Decoder) throws {
        
        let commonContainer = try decoder.container(keyedBy: CommonKeys.self)

        if let errorIsNull = try? commonContainer.decodeNil(forKey: .error), errorIsNull {
            error = nil
        } else if let error = try commonContainer.decodeIfPresent([String: Any].self, forKey: .error) {
            if let message = error["message"] as? String {
                let code = error["code"] as? Int
                self.error = .serviceResponseData(message, code ?? -1000)
            } else {
                self.error = .noData
            }
        } else {
            error = nil
        }

        if let data = try? commonContainer.decode([String: Any].self, forKey: .data) {
            self.data = data
        } else if let data = try? commonContainer.decode([Any].self, forKey: .data) {
            self.data = data
        } else if let data = try? commonContainer.decode(String.self, forKey: .data) {
            self.data = data
        } else {
            data = nil
        }
    }
}
