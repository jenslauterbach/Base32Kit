import XCTest
@testable import Base32Kit

final class Base32KitTests: XCTestCase {
    
    func testRFC4648TestVectors() {
        let testData: [String: String] = [
            "": "",
            "f": "MY======",
            "fo": "MZXQ====",
            "foo": "MZXW6===",
            "foob": "MZXW6YQ=",
            "fooba": "MZXW6YTB",
            "foobar": "MZXW6YTBOI======"
        ]
        
        for (input, expected) in testData {
            let encoded = Base32.encode(string: input)
            XCTAssertEqual(encoded, expected, "Input '\(input)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded).")
        }
    }

    static var allTests = [
        ("testExample", testRFC4648TestVectors),
    ]
}
