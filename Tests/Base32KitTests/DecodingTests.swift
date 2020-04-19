import XCTest
@testable import Base32Kit

final class DecodingTests: XCTestCase {
    
    static var allTests = [
        ("testRFC4648TestVectors", testRFC4648TestVectors),
    ]
    
    func testRFC4648TestVectors() {
        let testData: [String: String] = [
            "": "",
            "MY======": "f",
            "MZXQ====": "fo",
            "MZXW6===": "foo",
            "MZXW6YQ=": "foob",
            "MZXW6YTB": "fooba",
            "MZXW6YTBOI======": "foobar"
        ]
        
        for (input, expected) in testData {
            let decoded = Base32.decode(string: input)
            XCTAssertEqual(decoded, expected, "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded).")
        }
    }
}

