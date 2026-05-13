
import Testing
import Foundation
@testable import DiiaNetwork

final class ResponseMapperTests: Test {
    @Test("Mapping succeed if model without nested types, and with optional properties")
    func succeed_ifNoNestedTypes_andWithOptionalProperties() throws {
        let json = """
            {
                "id": 1,
                "name": "Any String"
            }
            """
        let jsonData = try #require(json.data(using: .utf8))
        
        let sut = makeSUT()
        let result: TestModel = try sut.map(data: jsonData)
        let expectedModel = TestModel(
            id: 1,
            name: "Any String"
        )
        
        #expect(result == expectedModel)
    }
    
    @Test("Mapping succeed if model with nested types, and without optional properties")
    func succeed_ifNestedTypes_andNoOptionalProperties() throws {
        let json = """
            {
                "id": 1,
                "name": "Any String",
                "nestedModel": {
                    "doubleValue": 123.123,
                    "timeStamp": 123456789
                }
            }
            """
        let jsonData = try #require(json.data(using: .utf8))

        let sut = makeSUT()
        let result: TestModel_NestedTypes = try sut.map(data: jsonData)
        let expectedModel = TestModel_NestedTypes(
            id: 1,
            name: "Any String",
            nestedModel: TestNestedModel(
                doubleValue: 123.123,
                timeStamp: 123456789
            )
        )
        
        #expect(result == expectedModel)
    }
    
    @Test("Mapping succeed if model with nested types, and with optional properties")
    func succeed_ifNestedTypes_andOptionalProperties() throws {
        let json = """
            {
                "id": 1,
                "nestedModel": {
                    "doubleValue": 123.123,
                    "timeStamp": 123456789
                }
            }
            """
        let jsonData = try #require(json.data(using: .utf8))

        let sut = makeSUT()
        let result: TestModel_NestedTypes_OptionalField = try sut.map(data: jsonData)
        let expectedModel = TestModel_NestedTypes_OptionalField(
            id: 1,
            name: nil,
            nestedModel: TestNestedModel(
                doubleValue: 123.123,
                timeStamp: 123456789
            )
        )
        
        #expect(result == expectedModel)
    }
    
    @Test("Mapping failed if JSON does not correspond to model")
    func failed_ifJSONDoesNotCorrespondToModel() throws {
        let json = """
            {
                "value": "Any String",
                "nestedModel": 1234
            }
            """
        let jsonData = try #require(json.data(using: .utf8))

        #expect(throws: anyErrorType) {
            let _: TestModel = try makeSUT().map(data: jsonData)
        }
    }
    
    @Test("Mapping failed if JSON is invalid")
    func failed_ifJSONIsInvalid() throws {
        let invalidJson = """
            {
                "value": \("AnyString")",
                "nestedModel": \("1234")
            }
            """
        let jsonData = try #require(invalidJson.data(using: .utf8))
        
        #expect(throws: anyErrorType) {
            let _: TestModel = try makeSUT().map(data: jsonData)
        }
    }
    
    @Test("Mapper uses injected decoder")
    func mapperUsesInjectedDecoder() throws {
        let rawId = 1
        let rawUserName = "John Doe"
        let rawBase64String = "aGVsbG8gd29ybGQ="    // "hello world" in base64
        let rawDateString = "2024-02-05T14:00:00Z"
        
        let json = """
               {
                   "id": \(rawId),
                   "created_at": "\(rawDateString)",
                   "user_name": "\(rawUserName)",
                   "base_64_data": "\(rawBase64String)"
               }
               """
        let jsonData = try #require(json.data(using: .utf8))
        let expectedBase64Data = try #require(Data(base64Encoded: rawBase64String))
        let expectedDate = try #require(ISO8601DateFormatter().date(from: rawDateString))
        
        let customDecoder = TestJSONDecoderConfig()
        let mapper = ResponseMapperImpl(decoder: customDecoder)
        
        let decodedModel: DecoderTestModel = try mapper.map(data: jsonData)
        
        #expect(decodedModel.id == rawId)
        #expect(decodedModel.userName == rawUserName)
        #expect(decodedModel.createdAt == expectedDate)
        #expect(decodedModel.base64Data == expectedBase64Data)
    }
    
    // MARK: - Helpers
    private func makeSUT(
        decoder: JSONDecoderConfigProtocol? = JSONDecoderConfigMock(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ResponseMapper {
        let mapper = ResponseMapperImpl(decoder: decoder)
        trackForMemoryLeaks(mapper, file: file, line: line)
        return mapper
    }
}

private final class TestJSONDecoderConfig: JSONDecoderConfigProtocol {
    private(set) var wasCalled = false
    
    func jsonDecoder() -> JSONDecoder {
        wasCalled = true
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dataDecodingStrategy = .base64
        return decoder
    }
}

private typealias TestRequired = Decodable & Equatable

private struct TestModel: TestRequired {
    let id: Int
    let name: String
}

private struct TestModel_OptionalField: TestRequired {
    let id: Int
    let name: String?
}

private struct TestModel_NestedTypes: TestRequired {
    let id: Int
    let name: String
    let nestedModel: TestNestedModel
}

private struct TestModel_NestedTypes_OptionalField: TestRequired {
    let id: Int
    let name: String?
    let nestedModel: TestNestedModel
}

struct TestNestedModel: TestRequired {
    let doubleValue: Double
    let timeStamp: Int64
}

struct DecoderTestModel: TestRequired {
    let id: Int
    let createdAt: Date
    let userName: String
    let base64Data: Data
}
