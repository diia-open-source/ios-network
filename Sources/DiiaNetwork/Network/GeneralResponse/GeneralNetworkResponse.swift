import Foundation

public protocol GeneralNetworkResponse: Decodable {
    /**
     Error description
     */
    var error: NetworkError? { get }
    
    /**
     Data
     */
    var data: Any? { get }
    
    func rawData(keyPath: String?) throws -> Data
}

extension GeneralNetworkResponse {
    public func rawData(keyPath: String?) throws -> Data {
        guard let data = data
            else {
                throw NetworkError.noData
        }
        
        let rawData: Data?
        if let keyPath = keyPath, !keyPath.isEmpty {
            guard let data = data as? [String: Any] else {
                throw NetworkError.noData
            }
            if let keyData = data[keyPath: keyPath], keyData as? NSNull == nil {
                rawData = try? JSONSerialization.data(withJSONObject: keyData, options: [])
            } else {
                throw NetworkError.noData
            }
        } else {
            rawData = try? JSONSerialization.data(withJSONObject: data, options: [])
        }
        
        if let rawData = rawData {
            return rawData
        } else {
            throw NetworkError.noData
        }
    }
}
