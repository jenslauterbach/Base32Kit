@testable import Base32Kit
import XCTest

final class Base32DecodingTests: XCTestCase {
    private let invalidAsciiCharacters: Set<UInt8> = {
        // Create a Set of all ASCII characters, including the following sets of characters:
        //
        // 1. ASCII control characters (0 - 31)
        // 2. ASCII printable characters (32 - 127)
        // 3. ASCII extended character set (128 - 255)
        var asciiCharacters = Set<UInt8>(0 ... 255)

        // Remove all valid characters as defined by the Base 32 alphabet (all upper case) from the list:
        asciiCharacters.subtract(Set(Base32.base32))

        // Remove the lowercase variants of the valid Base 32 alphabet from the list. The lowercase characters have a
        // "distance" of 32 from their uppercase variants.
        //
        // For example: The uppercase "A" has the decimal ASCII code of 65. The lowercase "a" has a decimal ASCII code
        // of 97. The "distance" between them is 32.
        asciiCharacters.subtract(Set(Base32.base32.map { $0 + 32 }))

        // Remove the padding character ("=") from the list, because it is allowed:
        asciiCharacters.remove(Base32.encodePaddingCharacter)

        // Remove the "NUL" control character. It can not be part of a String and therefore is a "non character". There
        // is a separate test to specifically test for the NUL character.
        asciiCharacters.remove(0)

        return asciiCharacters
    }()

    private let invalidAsciiCharactersHex: Set<UInt8> = {
        // Create a Set of all ASCII characters, including the following sets of characters:
        //
        // 1. ASCII control characters (0 - 31)
        // 2. ASCII printable characters (32 - 127)
        // 3. ASCII extended character set (128 - 255)
        var asciiCharacters = Set<UInt8>(0 ... 255)

        // Remove all valid characters as defined by the Base 32 alphabet (all upper case) from the list:
        asciiCharacters.subtract(Set(Base32.base32hex))

        // Remove the lowercase variants of the valid Base 32 alphabet from the list. The lowercase characters have a
        // "distance" of 32 from their uppercase variants.
        //
        // For example: The uppercase "A" has the decimal ASCII code of 65. The lowercase "a" has a decimal ASCII code
        // of 97. The "distance" between them is 32.
        asciiCharacters.subtract(Set(Base32.base32hex.map { $0 + 32 }))

        // Remove the padding character ("=") from the list, because it is allowed:
        asciiCharacters.remove(Base32.encodePaddingCharacter)

        // Remove the "NUL" control character. It can not be part of a String and therefore is a "non character". There
        // is a separate test to specfically test for the NUL character.
        asciiCharacters.remove(0)

        return asciiCharacters
    }()

    func testTotp() throws {
        let input = "YBJC77RSAGQG4BNPIAWNHYQQBLAEFQKS4PZGWXIP6BXXNSZY37VQ"
        let notStrict: DecodingOptions = []
        let decoded = try Base32.decode(encoded: input, options: notStrict)
        print(decoded)
    }

    func testRFC4648TestVectors() throws {
        let testData: [String: String] = [
            "": "",
            "MY======": "f",
            "MZXQ====": "fo",
            "MZXW6===": "foo",
            "MZXW6YQ=": "foob",
            "MZXW6YTB": "fooba",
            "MZXW6YTBOI======": "foobar",
        ]

        for (input, expected) in testData {
            let decoded = try Base32.decode(encoded: input)
            XCTAssertEqual(
                decoded,
                Array(expected.utf8),
                "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded)."
            )
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
            "mzxw6ytboi======": "foobar",
        ]

        for (input, expected) in testData {
            let decoded = try Base32.decode(encoded: input)
            XCTAssertEqual(
                decoded,
                Array(expected.utf8),
                "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded)."
            )
        }
    }

    // Length has to be checked differently. It probably does make sense to add DecodingOptions with an option for
    // strict and non-strict validation.
    func deactivated_testInvalidLength() {
        let testData = generateRandomInvalidLengthStrings(count: 100, alphabet: Base32.base32)

        for encoded in testData {
            assert(
                try Base32.decode(encoded: encoded),
                throws: Base32.DecodingError.invalidLength
            )
        }
    }

    func testInvalidAsciiCharacters() {
        for character in invalidAsciiCharacters {
            let encoded = String(format: "%c=======", character)
            assert(
                try Base32.decode(encoded: encoded),
                throws: Base32.DecodingError.illegalCharacter
            )
        }
    }

    func testEmoji() {
        let emojiRanges = [
            0x1F600 ... 0x1F636,
            0x1F645 ... 0x1F64F,
            0x1F910 ... 0x1F91F,
            0x1F30D ... 0x1F52D,
        ]

        for subRange in emojiRanges {
            for emojiScalar in subRange {
                guard let emoji = UnicodeScalar(emojiScalar) else {
                    continue
                }

                let encoded = String(emoji) + "======="
                assert(
                    try Base32.decode(encoded: encoded),
                    throws: Base32.DecodingError.illegalCharacter
                )
            }
        }
    }

    func testTestEmoji() {
        let emoji = UnicodeScalar(0x1F600)
        let encoded = String(emoji!) + "======="

        assert(
                try Base32.decode(encoded: encoded),
                throws: Base32.DecodingError.illegalCharacter
        )
    }

    func testLineBreaks() throws {
        let testStrings: [String] = [
            // New lines at the end of the string:
            "mzxw6yt\n",
            "mzxw6yt\r\n",

            // New lines in the middle of the string:
            "mzxw\nytb",
            "mzxw\r\nytb",

            // New lines at the beginning of the string:
            "\nzxw6ytb",
            "\r\nzxw6ytb",
        ]

        for encoded in testStrings {
            assert(
                try Base32.decode(encoded: encoded),
                throws: Base32.DecodingError.illegalCharacter
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
    func testNulCharacter() {
        let bytes: [UInt8] = [
            77, // M
            90, // Z
            0, // NUL <-- This should not break the decoder.
            81, // Q
            61, // =
            61, // =
            61, // =
            61, // =
        ]

        let encoded = String(decoding: bytes, as: Unicode.UTF8.self)

        assert(
            try Base32.decode(encoded: encoded),
            throws: Base32.DecodingError.illegalCharacter
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
            "mzXw6YTBoI======": "foobar",
        ]

        for (input, expected) in testData {
            let decoded = try Base32.decode(encoded: input)
            XCTAssertEqual(
                decoded,
                Array(expected.utf8),
                "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded)."
            )
        }
    }

    func testHexRFC4648TestVectors() throws {
        let stringsToDecode: [String: String] = [
            "": "",
            "CO======": "f",
            "CPNG====": "fo",
            "CPNMU===": "foo",
            "CPNMUOG=": "foob",
            "CPNMUOJ1": "fooba",
            "CPNMUOJ1E8======": "foobar",
        ]

        for (stringToDecode, expected) in stringsToDecode {
            let encoded = try Base32.decode(encoded: stringToDecode, alphabet: .hex)
            XCTAssertEqual(
                encoded,
                Array(expected.utf8),
                "Input '\(stringToDecode)' could not be encoded correctly. Expected: \(expected), Actual: \(encoded)."
            )
        }
    }

    func testHexLowerCaseRFC4648TestVectors() throws {
        let testData: [String: String] = [
            "": "",
            "co======": "f",
            "cpng====": "fo",
            "cpnmu===": "foo",
            "cpnmuog=": "foob",
            "cpnmuoj1": "fooba",
            "cpnmuoj1e8======": "foobar",
        ]

        for (input, expected) in testData {
            let decoded = try Base32.decode(encoded: input, alphabet: .hex)
            XCTAssertEqual(
                decoded,
                Array(expected.utf8),
                "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded)."
            )
        }
    }

    func deactivated_testHexInvalidLength() {
        let testData = generateRandomInvalidLengthStrings(count: 100, alphabet: Base32.base32hex)

        for encoded in testData {
            assert(
                try Base32.decode(encoded: encoded, alphabet: .hex),
                throws: Base32.DecodingError.invalidLength
            )
        }
    }

    func testHexInvalidAsciiCharacters() {
        for character in invalidAsciiCharactersHex {
            let encoded = String(format: "%c=======", character)

            assert(
                try Base32.decode(encoded: encoded, alphabet: .hex),
                throws: Base32.DecodingError.illegalCharacter
            )
        }
    }

    func testHexEmoji() {
        let emojiRanges = [
            0x1F600 ... 0x1F636,
            0x1F645 ... 0x1F64F,
            0x1F910 ... 0x1F91F,
            0x1F30D ... 0x1F52D,
        ]

        for subRange in emojiRanges {
            for emojiScalar in subRange {
                guard let emoji = UnicodeScalar(emojiScalar) else {
                    continue
                }

                let encoded = String(emoji) + "======="
                assert(
                    try Base32.decode(encoded: encoded, alphabet: .hex),
                    throws: Base32.DecodingError.illegalCharacter
                )
            }
        }
    }

    func testHexLineBreaks() throws {
        let testStrings: [String] = [
            // New lines at the end of the string:
            "cpnmuog\n",
            "cpnmuog\r\n",

            // New lines in the middle of the string:
            "cpnm\noj1",
            "cpnm\r\noj1",

            // New lines at the beginning of the string:
            "\npnmuoj1",
            "\r\npnmuoj1",
        ]

        for encoded in testStrings {
            assert(
                try Base32.decode(encoded: encoded, alphabet: .hex),
                throws: Base32.DecodingError.illegalCharacter
            )
        }
    }

    func testHexNulCharacter() {
        let bytes: [UInt8] = [
            67, // C
            80, // P
            0, // NUL <-- This should not break the decoder.
            71, // G
            61, // =
            61, // =
            61, // =
            61, // =
        ]

        let encoded = String(decoding: bytes, as: Unicode.UTF8.self)

        assert(
            try Base32.decode(encoded: encoded, alphabet: .hex),
            throws: Base32.DecodingError.illegalCharacter
        )
    }

    func testHexCaseSensitivity() throws {
        let testData: [String: String] = [
            "": "",
            "CO======": "f",
            "CpNg====": "fo",
            "CPnmU===": "foo",
            "cPNMUoG=": "foob",
            "CPNMUOj1": "fooba",
            "cpNmUOJ1e8======": "foobar",
        ]

        for (input, expected) in testData {
            let decoded = try Base32.decode(encoded: input, alphabet: .hex)
            XCTAssertEqual(
                decoded,
                Array(expected.utf8),
                "Input '\(input)' could not be decoded correctly. Expected: \(expected), Actual: \(decoded)."
            )
        }
    }

    private func generateRandomInvalidLengthStrings(count: Int, alphabet: [UInt8]) -> [String] {
        var result = [String]()

        while result.count != count {
            let length = Int.random(in: 1 ... 1000)

            if length % 8 == 0 {
                continue
            }

            let bytes = (0 ..< length).map { _ in alphabet.randomElement()! }
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
