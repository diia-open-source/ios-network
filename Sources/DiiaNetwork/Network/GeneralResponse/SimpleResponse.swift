
import Foundation

struct SimpleResponse: GeneralNetworkResponse {
    /**
     Error description
     */
    var error: NetworkError?

    /**
     Data
     */
    var data: Any?

    init(from decoder: Decoder) throws {
        let commonContainer = try decoder.container(keyedBy: JSONCodingKeys.self)

        let dict = try commonContainer.decode([String: Any].self)
        self.data = dict
    }
}
