
import Foundation
@testable import DiiaNetwork

class JSONDecoderConfigMock: JSONDecoderConfigProtocol {
    func jsonDecoder() -> JSONDecoder {
        return .init()
    }
}
