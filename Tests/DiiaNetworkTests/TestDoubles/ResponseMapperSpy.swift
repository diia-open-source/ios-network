
import Foundation
@testable import DiiaNetwork

final class ResponseMapperSpy: ResponseMapper {
    private(set) var mapCallsCount = 0
    var onMapRequested: ((RequestExecutionSteps) -> Void)?
    
    private let mapper: ResponseMapper
    
    init(mapper: ResponseMapper) {
        self.mapper = mapper
    }
    
    func map<T>(data: Data) throws(ResponseMapperError) -> T where T : Decodable {
        mapCallsCount += 1
        onMapRequested?(.dataMapping)
        
        return try mapper.map(data: data)
    }
}
