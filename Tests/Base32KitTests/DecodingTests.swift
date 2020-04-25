import XCTest
@testable import Base32Kit

final class DecodingTests: XCTestCase {
    
    static var allTests = [
        ("testRFC4648TestVectors", testRFC4648TestVectors),
        ("testLowerCaseRFC4648TestVectors", testLowerCaseRFC4648TestVectors),
        ("testInvalidLength", testInvalidLength),
        ("testInvalidAsciiCharacters", testInvalidAsciiCharacters),
        ("testEmoji", testEmoji),
        ("testLineBreaks", testLineBreaks),
        ("testMisplacedPaddingCharacter", testMisplacedPaddingCharacter),
        ("testNulCharacter", testNulCharacter),
        ("testCaseSensitivity", testCaseSensitivity)
    ]
    
    private let invalidAsciiCharacters: Set<UInt8> = {
        // Create a Set of all ASCII characters, including the following sets of characters:
        //
        // 1. ASCII control characters (0 - 31)
        // 2. ASCII printable characters (32 - 127)
        // 3. ASCII extended character set (128 - 255)
        var asciiCharacters = Set<UInt8>(0...255)
        
        // Remove all valid characters as defined by the Base 32 alphabet (all upper case) from the list:
        asciiCharacters.subtract(Set(Base32.alphabet))
        
        // Remove the lowercase variants of the valid Base 32 alphabet from the list. The lowercase characters have a
        // "distance" of 32 from their uppercase variants.
        //
        // For example: The uppercase "A" has the decimal ASCII code of 65. The lowercase "a" has a decimal ASCII code
        // of 97. The "distance" between them is 32.
        asciiCharacters.subtract(Set(Base32.alphabet.map { $0 + 32 }))
        
        // Remove the padding character ("=") from the list, because it is allowed:
        asciiCharacters.remove(Base32.encodePaddingCharacter)
        
        // Remove the "NUL" control character. It can not be part of a String and therefore is a "non character". There
        // is a separate test to specfically test for the NUL character.
        asciiCharacters.remove(0)
        
        return asciiCharacters
    }()
    
    func testRFC4648TestVectors() throws {
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
            let decoded = try Base32.decode(string: input)
            XCTAssertEqual(decoded, expected, "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded).")
        }
    }
    
    func testLowerCaseRFC4648TestVectors() throws {
        let testData: [String: String] = [
            "": "",
            "my======": "f",
            "mzxq====": "fo",
            "mzxw6===": "foo",
            "mzxw6yq=": "foob",
            "mzxw6ytb": "fooba",
            "mzxw6ytboi======": "foobar"
        ]
        
        for (input, expected) in testData {
            let decoded = try Base32.decode(string: input)
            XCTAssertEqual(decoded, expected, "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded).")
        }
    }
    
    func testInvalidLength() {
        let testData = generateRandomInvalidLengthStrings(count: 100)
        
        for encoded in testData {
            assert(
                try Base32.decode(string: encoded),
                throws: Base32.DecodingError.invalidLength
            )
        }
    }
    
    func testInvalidAsciiCharacters() {
        for character in invalidAsciiCharacters {
            let encoded = String(format: "%c=======", character)
            
            assert(
                try Base32.decode(string: encoded),
                throws: Base32.DecodingError.invalidCharacter([Character(UnicodeScalar(character))])
            )
        }
    }
    
    // TODO: Expand this test. There are a lot of emojis and in theory all of them could be tested. On the other hand
    // emojis are a moving "target". Contrary to ASCII, the list of emoji "characters" is expanding every year.
    func testEmoji() {
        let emojis: [String] = ["😀"]
        
        for emoji in emojis {
            let encoded = emoji + "======="
            assert(
                try Base32.decode(string: encoded),
                throws: Base32.DecodingError.invalidCharacter([Character(emoji)])
            )
        }
    }
    
    func testLineBreaks() throws {
        let testStrings: [String: String] = [
            // New lines at the end of the string:
            "a======\n": "\n",
            "a======\r\n": "\r\n",
            
            // New lines in the middle of the string:
            "a===\n===": "\n",
            "a===\r\n===": "\r\n",
            
            // New lines at the beginning of the string:
            "\na======": "\n",
            "\r\na======": "\r\n"
        ]
        
        for (encoded, invalidCharacter) in testStrings {
            assert(
                try Base32.decode(string: encoded),
                throws: Base32.DecodingError.invalidCharacter([Character(invalidCharacter)])
            )
        }
    }
    
    func testMisplacedPaddingCharacter() {
        let testStrings: [String] = [
            // Only padding (not allowed):
            "========",
            
            // Padding at the beginning of a "valid" Base 32 encoded String:
            "=ZXW6===",
            
            // Move padding through a valid String:
            "=ZXW6YTB",
            "M=XW6YTB",
            "MZ=W6YTB",
            "MZX=6YTB",
            "MZXW=YTB",
            "MZXW6=TB",
            "MZXW6Y=B",
            
            // Padding at different invalid positions:
            "M=XW6Y=B",
            "=ZXW6Y=B",
            
            // Invalid padding in a Base 32 encoded String that is longer than a single "block":
            "================",
            "=ZXW6YTBOI======",
            "MZXW6Y=BOI======",
            "MZ=W6Y=BOI======",
            "=ZXW6Y=BOI======",
        ]
        
        for encoded in testStrings {
            assert(
                try Base32.decode(string: encoded),
                throws: Base32.DecodingError.invalidPaddingCharacters
            )
        }
    }
    
    /// Tests if decoding breaks if the string contains a NUL character.
    ///
    /// As stated in RFC4648, section 12:
    ///
    /// "A decoder should not break on invalid input including, e.g., embedded NUL characters (ASCII 0)."
    ///
    /// - SeeAlso: https://tools.ietf.org/html/rfc4648#section-12
    private func testNulCharacter() {
        let bytes: [UInt8] = [
            77, // M
            90, // Z
             0, // NUL <-- This should not break the decoder.
            81, // Q
            61, // =
            61, // =
            61, // =
            61  // =
        ]
        
        let encoded = String(decoding: bytes, as: Unicode.UTF8.self)
        
        assert(
            try Base32.decode(string: encoded),
            throws: Base32.DecodingError.invalidCharacter([Character(UnicodeScalar(0))])
        )
    }
    
    func testCaseSensitivity() throws {
        let testData: [String: String] = [
            "": "",
            "MY======": "f",
            "MzXq====": "fo",
            "MZxw6===": "foo",
            "mZXW6yQ=": "foob",
            "MZXW6Ytb": "fooba",
            "mzXw6YTBoI======": "foobar"
        ]
        
        for (input, expected) in testData {
            let decoded = try Base32.decode(string: input)
            XCTAssertEqual(decoded, expected, "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded).")
        }
    }
    
    private func generateRandomInvalidLengthStrings(count: Int) -> [String] {
        var result = [String]()
        
        while result.count != count {
            let length = Int.random(in: 1...1000)
            
            if length % 8 == 0 {
                continue
            }
            
            let bytes = (0..<length).map{_ in Base32.alphabet.randomElement()!}
            result.append(String(decoding: bytes, as: Unicode.UTF8.self))
        }
        
        return result
    }
}

extension XCTestCase {
    func assert<T, E: Error & Equatable>(
        _ expression: @autoclosure () throws -> T,
        throws error: E,
        in file: StaticString = #file,
        line: UInt = #line
    ) {
        var thrownError: Error?

        XCTAssertThrowsError(try expression(),
                             file: file, line: line) {
            thrownError = $0
        }

        XCTAssertTrue(
            thrownError is E,
            "Unexpected error type: \(type(of: thrownError))",
            file: file, line: line
        )

        XCTAssertEqual(
            thrownError as? E, error,
            file: file, line: line
        )
    }
}
