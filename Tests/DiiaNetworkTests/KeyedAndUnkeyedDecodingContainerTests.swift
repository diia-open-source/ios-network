import XCTest
@testable import DiiaNetwork

class KeyedAndUnkeyedDecodingContainerTests: XCTestCase {
    let jsonOnlyMandatory = """
            {
                "nestedDict": {
                    "key1": "value1",
                    "key2": 42,
                    "key3": 3.14,
                    "key4": true,
                    "key5": {"nestedDict-nestedDict-key1": "nestedDict-nestedDict-value1"},
                    "key6": ["nestedDict-nestedArray-value1", "nestedDict-nestedArray-value2"]
                },
                "nestedArray": [
                    "value1",
                    2,
                    false,
                    null,
                    {"nestedArray-NestedDict-Key1": "nestedArray-NestedDict-Value1"},
                    ["nestedArray-nestedArray-Value1", "nestedArray-nestedArray-Value2"]
                ]
            }
            """.data(using: .utf8)

    let jsonOptionalFields = """
            {
                "nestedDict": {"key1": "value1"},
                "nestedDictOptional": {"key1": "value1"},
                "nestedArray": ["value1", 2],
                "nestedArrayOptional": ["value3", 3.14]
            }
            """.data(using: .utf8)

    override func setUpWithError() throws {
        try super.setUpWithError()
        TestModelDecodeResultCallbacks.checkDecodeDict = nil
        TestModelDecodeResultCallbacks.checkDecodeDictIfPresent = nil
        TestModelDecodeResultCallbacks.checkDecodeArray = nil
        TestModelDecodeResultCallbacks.checkDecodeArrayIfPresent = nil
    }

    func testDecodeDict_requiredFieldsPresented() {

        guard let jsonOnlyMandatory else {
            XCTFail("testDecodeDict_requiredFieldsPresented: data is not inited")
            return
        }

        let decoder = JSONDecoder()
        TestModelDecodeResultCallbacks.checkDecodeDict = { result in
            XCTAssertEqual(result["key1"] as? String, "value1")
            XCTAssertEqual(result["key2"] as? Int, 42)
            XCTAssertEqual(result["key3"] as? Double, Double(3.14))
            XCTAssertEqual(result["key4"] as? Bool, true)
            XCTAssertEqual(result["key5"] as? [String: String], ["nestedDict-nestedDict-key1": "nestedDict-nestedDict-value1"])
            XCTAssertEqual(result["key6"] as? [String], ["nestedDict-nestedArray-value1", "nestedDict-nestedArray-value2"])
        }
        XCTAssertNoThrow(try decoder.decode(TestModel.self, from: jsonOnlyMandatory))
    }

    func testDecodeArray_requiredFieldsPresented() {

        guard let jsonOnlyMandatory else {
            XCTFail("testDecodeArray_requiredFieldsPresented: data is not inited")
            return
        }

        let decoder = JSONDecoder()
        TestModelDecodeResultCallbacks.checkDecodeDict = { result in
            XCTAssertEqual(result["key1"] as? String, "value1")
            XCTAssertEqual(result["key2"] as? Int, 42)
            XCTAssertEqual(result["key3"] as? Double, Double(3.14))
            XCTAssertEqual(result["key4"] as? Bool, true)
            XCTAssertEqual(result["key5"] as? [String: String], ["nestedDict-nestedDict-key1": "nestedDict-nestedDict-value1"])
            XCTAssertEqual(result["key6"] as? [String], ["nestedDict-nestedArray-value1", "nestedDict-nestedArray-value2"])
        }
        TestModelDecodeResultCallbacks.checkDecodeDictIfPresent = { result in
            XCTAssertNil(result)
        }
        TestModelDecodeResultCallbacks.checkDecodeArray = { result in
            XCTAssertEqual(result[0] as? String, "value1")
            XCTAssertEqual(result[1] as? Double, Double(2))
            XCTAssertEqual(result[2] as? Bool, false)
            XCTAssertEqual(result[3] as? NSNull, NSNull())
            XCTAssertEqual((result[4] as? [String: Any])?["nestedArray-NestedDict-Key1"] as? String, "nestedArray-NestedDict-Value1")
            XCTAssertEqual((result[5] as? [Any])?[0] as? String, "nestedArray-nestedArray-Value1")
            XCTAssertEqual((result[5] as? [Any])?[1] as? String, "nestedArray-nestedArray-Value2")
        }
        TestModelDecodeResultCallbacks.checkDecodeArrayIfPresent = { result in
            XCTAssertNil(result)
        }
        XCTAssertNoThrow(try decoder.decode(TestModel.self, from: jsonOnlyMandatory))
    }

    func testIfPresented_onlyRequiredFieldsPresented() {

        guard let jsonOnlyMandatory else {
            XCTFail("testDecodeArray_requiredFieldsPresented: data is not inited")
            return
        }

        let decoder = JSONDecoder()
        TestModelDecodeResultCallbacks.checkDecodeDictIfPresent = { result in
            XCTAssertNil(result)
        }
        TestModelDecodeResultCallbacks.checkDecodeArrayIfPresent = { result in
            XCTAssertNil(result)
        }
        XCTAssertNoThrow(try decoder.decode(TestModel.self, from: jsonOnlyMandatory))
    }

    func testDecode_requiredFieldsNotPresented() {
        let json = """
            {
                "dict": { "key1": "value1"}
            }
            """.data(using: .utf8)

        guard let json else {
            XCTFail("testDecode_requiredFieldsNotPresented: data is not inited")
            return
        }
        let decoder = JSONDecoder()
        XCTAssertThrowsError(try decoder.decode(TestModel.self, from: json))
    }

    func testDecodeDictIfPresented_optionalFieldsPresented() {
        guard let jsonOptionalFields else {
            XCTFail("testDecodeDictIfPresented_optionalFieldsPresented: data is not inited")
            return
        }

        let decoder = JSONDecoder()
        TestModelDecodeResultCallbacks.checkDecodeDictIfPresent = { result in
            XCTAssertEqual(result?["key1"] as? String, "value1")
        }
        XCTAssertNoThrow(try decoder.decode(TestModel.self, from: jsonOptionalFields))
    }

    func testDecodeArrayIfPresented_optionalFieldsPresented() {
        guard let jsonOptionalFields else {
            XCTFail("testDecodeArrayIfPresented_optionalFieldsPresented: data is not inited")
            return
        }

        let decoder = JSONDecoder()
        TestModelDecodeResultCallbacks.checkDecodeArrayIfPresent = { result in
            XCTAssertEqual(result?[0] as? String, "value3")
            XCTAssertEqual(result?[1] as? Double, 3.14)
        }
        XCTAssertNoThrow(try decoder.decode(TestModel.self, from: jsonOptionalFields))
    }
}

private enum TestModelDecodeResultCallbacks {
    static var checkDecodeDict: (([String: Any]) -> Void)?
    static var checkDecodeDictIfPresent: (([String: Any]?) -> Void)?
    static var checkDecodeArray: (([Any]) -> Void)?
    static var checkDecodeArrayIfPresent: (([Any]?) -> Void)?
}

private struct TestModel: Decodable {
    public let nestedDict: [String: Any]
    public let nestedDictOptional: [String: Any]?
    public let nestedArray: [Any]
    public let nestedArrayOptional: [Any]?

    enum CommonKeys: String, CodingKey {
        case nestedDict
        case nestedDictOptional
        case nestedArray
        case nestedArrayOptional
    }

    public init(from decoder: Decoder) throws {
        let commonContainer = try decoder.container(keyedBy: CommonKeys.self)
        nestedDict = try commonContainer.decode([String: Any].self, forKey: .nestedDict)
        TestModelDecodeResultCallbacks.checkDecodeDict?(nestedDict)
        nestedDictOptional = try commonContainer.decodeIfPresent([String: Any].self, forKey: .nestedDictOptional)
        TestModelDecodeResultCallbacks.checkDecodeDictIfPresent?(nestedDictOptional)
        nestedArray = try commonContainer.decode([Any].self, forKey: .nestedArray)
        TestModelDecodeResultCallbacks.checkDecodeArray?(nestedArray)
        nestedArrayOptional = try commonContainer.decodeIfPresent([Any].self, forKey: .nestedArrayOptional)
        TestModelDecodeResultCallbacks.checkDecodeArrayIfPresent?(nestedArrayOptional)
    }
}
