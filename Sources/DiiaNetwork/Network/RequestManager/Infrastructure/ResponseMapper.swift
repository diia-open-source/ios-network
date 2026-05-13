
import Foundation

protocol ResponseMapper {
    func map<T: Decodable>(data: Data) throws(ResponseMapperError) -> T
}

enum ResponseMapperError: Error {
    case mappingError(Error)
}

final class ResponseMapperImpl: ResponseMapper {
    // MARK: - Properties
    private let decoder: JSONDecoderConfigProtocol?
    
    // MARK: - Init
    init(decoder: JSONDecoderConfigProtocol?) {
        self.decoder = decoder
    }
    
    // MARK: - Public
    func map<T: Decodable>(data: Data) throws(ResponseMapperError) -> T {
        if data.isEmpty,
           let optionalType = T.self as? ExpressibleByNilLiteral.Type,
           let nilValue = optionalType.init(nilLiteral: ()) as? T {
            return nilValue
        }

        do {
            let result = try (decoder?.jsonDecoder() ?? JSONDecoder()).decode(T.self, from: data)
            return result
        } catch {
            throw .mappingError(error)
        }
    }
}
