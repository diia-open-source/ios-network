
import Foundation
@testable import DiiaNetwork

final class JSONDecoderConfigMock: JSONDecoderConfigProtocol {
    func jsonDecoder() -> JSONDecoder {
        return .init()
    }
}
