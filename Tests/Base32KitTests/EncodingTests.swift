import XCTest
@testable import Base32Kit

final class EncodingTests: XCTestCase {
    
    public static var allTests = [
        ("testRFC4648TestVectors", testRFC4648TestVectors),
        ("testCapacityFormula", testCapacityFormula)
    ]
    
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
    
    func testCapacityFormula() {
        let testData: [Int: Int] = [
            1: 8,
            2: 8,
            3: 8,
            4: 8,
            5: 8,
            6: 16,
            10: 16,
            11: 24,
            20: 32,
            21: 40,
            100: 160
        ]
        
        for (count, expectedCapacity) in testData {
            let result = ((count + 4) / 5) * 8
            XCTAssertEqual(result, expectedCapacity)
        }
    }
}
