import XCTest
@testable import Base32Kit

final class EncodingTests: XCTestCase {
    
    public static var allTests = [
        ("testRFC4648TestVectors", testRFC4648TestVectors),
        ("testCapacityFormula", testCapacityFormula),
        ("testEmoji", testEmoji)
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
    
    func testSentences() {
        // See: https://en.wikipedia.org/wiki/Harvard_sentences
        let sentences: [String: String] = [
            "Oak is strong and also gives shade.": "J5QWWIDJOMQHG5DSN5XGOIDBNZSCAYLMONXSAZ3JOZSXGIDTNBQWIZJO",
            "Cats and dogs each hate the other.": "INQXI4ZAMFXGIIDEN5TXGIDFMFRWQIDIMF2GKIDUNBSSA33UNBSXELQ=",
            "The pipe began to rust while new.": "KRUGKIDQNFYGKIDCMVTWC3RAORXSA4TVON2CA53INFWGKIDOMV3S4===",
            "Open the crate but don't break the glass.": "J5YGK3RAORUGKIDDOJQXIZJAMJ2XIIDEN5XCO5BAMJZGKYLLEB2GQZJAM5WGC43TFY======",
            "Add the sum to the product of these three.": "IFSGIIDUNBSSA43VNUQHI3ZAORUGKIDQOJXWI5LDOQQG6ZRAORUGK43FEB2GQ4TFMUXA====",
            "Thieves who rob friends deserve jail.": "KRUGSZLWMVZSA53IN4QHE33CEBTHE2LFNZSHGIDEMVZWK4TWMUQGUYLJNQXA====",
            "The ripe taste of cheese improves with age.": "KRUGKIDSNFYGKIDUMFZXIZJAN5TCAY3IMVSXGZJANFWXA4TPOZSXGIDXNF2GQIDBM5SS4===",
            "Act on these orders with great speed.": "IFRXIIDPNYQHI2DFONSSA33SMRSXE4ZAO5UXI2BAM5ZGKYLUEBZXAZLFMQXA====",
            "The hog crawled under the high fence.": "KRUGKIDIN5TSAY3SMF3WYZLEEB2W4ZDFOIQHI2DFEBUGSZ3IEBTGK3TDMUXA====",
            "Move the vat over the hot fire.": "JVXXMZJAORUGKIDWMF2CA33WMVZCA5DIMUQGQ33UEBTGS4TFFY======"
        ]
        
        for (sentence, expected) in sentences {
            let encoded = Base32.encode(string: sentence)
            XCTAssertEqual(encoded, expected, "Input '\(sentence)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded).")
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
    
    func testEmoji() throws {
        let testData: [String: String] = [
            "😀": "6CPZRAA=",
            "Hello World ❤️": "JBSWY3DPEBLW64TMMQQOFHNE564I6==="
        ]
        
        for (input, expected) in testData {
            let encoded = Base32.encode(string: input)
            XCTAssertEqual(encoded, expected, "Input '\(input)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded).")
        }
    }
    
    func testHexRFC4648TestVectors() {
        let stringsToEncode: [String: String] = [
            "": "",
            "f": "CO======",
            "fo": "CPNG====",
            "foo": "CPNMU===",
            "foob": "CPNMUOG=",
            "fooba": "CPNMUOJ1",
            "foobar": "CPNMUOJ1E8======"
        ]
        
        for (stringToEncode, expected) in stringsToEncode {
            let encoded = Base32.encodeHex(string: stringToEncode)
            XCTAssertEqual(encoded, expected, "Input '\(stringToEncode)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded).")
        }
    }
}
