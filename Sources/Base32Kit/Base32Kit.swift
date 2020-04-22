// MARK: Public API
public struct Base32 {
    
    /// Encodes the given `string` with the standard Base 32 alphabet.
    ///
    /// If the given `string` is empty, the encoded `String` will also be empty. The  result can contain padding (`=`), if the given `string` does not
    /// contain a multiple of 5 input characters.
    ///
    /// Examples:
    ///
    ///     Base32.encode("")       // Result: ""
    ///     Base32.encode("f")      // Result: "MY======"
    ///     Base32.encode("fo")     // Result: "MZXQ===="
    ///     Base32.encode("foo")    // Result: "MZXW6==="
    ///     Base32.encode("foob")   // Result: "MZXW6YQ="
    ///     Base32.encode("fooba")  // Result: "MZXW6YTB"
    ///     Base32.encode("foobar") // Result: "MZXW6YTBOI======"
    ///
    /// - Parameter string: The UTF8 string to encode.
    ///
    /// - Returns: Base 32 encoded `String` or empty `String` if the given `string` is empty.
    public static func encode(string: String) -> String {
        return encode(bytes: Array(string.utf8))
    }
    
    /// Decodes the given `string` with the standard Base 32 alphabet.
    ///
    /// If the given `string` is empty, the decoded `String` will also be empty. This method is case in-senstive.
    ///
    /// Examples:
    ///
    ///     Base32.decode("")                   // Result: ""
    ///     Base32.decode("MY======")           // Result: "f"
    ///     Base32.decode("MZXQ====")           // Result: "fo"
    ///     Base32.decode("MZXW6===")           // Result: "foo"
    ///     Base32.decode("MZXW6YQ=")           // Result: "foob"
    ///     Base32.decode("MZXW6YTB")           // Result: "fooba"
    ///     Base32.decode("MZXW6YTBOI======")   // Result: "foobar"
    ///
    /// - Parameter string: The UTF8 string to decode.
    ///
    /// - Returns: Decoded UTF8 string or empty `String` if the given `string` is empty.
    ///
    /// - Throws:
    ///     - `DecodingError.invalidLength` if the encoded string has invalid length (is not a multiple of 8 or empty).
    ///     - `DecodingError.invalidCharacter` if the encoded string contains one or more invalid characters.
    public static func decode(string: String) throws -> String {
        guard !string.isEmpty else {
            return ""
        }
        
        // The length of the input string has to be checked at this point, based on the given String instead of the
        // byte array that is handed off to the internal 'decode' method. Unicode strings can contain eight "visible"
        // characters, but those eight visible characters are constructed of more than eight separate bytes. If the
        // length of the byte array is checked, it might lead to false positives.
        guard string.count % 8 == 0 else {
            throw Base32.DecodingError.invalidLength
        }
        
        if let invalidCharacter = invalidCharacters(in: string) {
            throw Base32.DecodingError.invalidCharacter(invalidCharacter)
        }
        
        if invalidPadding(in: string) {
            throw Base32.DecodingError.invalidPaddingCharacters
        }
        
        return try decode(bytes: Array(string.utf8))
    }
    
    private static func invalidPadding(in string: String) -> Bool {
        // TODO: Refactor this very naive implementation to find "misplaced" padding characters in the given String.
        
        // The String is never allowed to start with a padding character:
        if string.starts(with: "=") {
            return true
        }
        
        var foundPadding = false
        
        for character in string {
            if foundPadding && (character.isLetter || character.isNumber) {
                return true
            }
            
            if character == "=" {
                foundPadding = true
            }
        }
        
        return false
    }
    
    private static func invalidCharacters(in string: String) -> [Character]? {
        var invalidCharacters: [Character] = []
        
        for character in string {
            if !character.isASCII {
                invalidCharacters.append(character as Character)
                continue
            }
            
            guard let ascii = character.asciiValue else {
                invalidCharacters.append(character as Character)
                continue
            }
            
            if ascii == encodePaddingCharacter {
                continue
            }
            
            let value = alphabetDecodeTable[Int(ascii)]
            if value <= 31 {
                continue
            }
            
            invalidCharacters.append(character as Character)
        }
        
        return invalidCharacters.isEmpty ? nil : invalidCharacters
    }

}

// MARK: Encoding (Private)
extension Base32 {
    
    private static func encode<Buffer: Collection>(bytes: Buffer) -> String where Buffer.Element == UInt8 {
        if bytes.isEmpty {
            return ""
        }
        
        var input = bytes.makeIterator()
        
        var output = [UInt8]()
        let capacity = ((bytes.count + 4) / 5) * 8
        output.reserveCapacity(capacity)
        
        while let firstByte = input.next() {
            let secondByte = input.next()
            let thirdByte = input.next()
            let fourthByte = input.next()
            let fifthByte = input.next()
            
            let firstChar = Base32.encode(firstByte: firstByte)
            let secondChar = Base32.encode(firstByte: firstByte, secondByte: secondByte)
            let thirdChar = Base32.encode(secondByte: secondByte)
            let fourthChar = Base32.encode(secondByte: secondByte, thirdByte: thirdByte)
            let fifthChar = Base32.encode(thirdByte: thirdByte, fourthByte: fourthByte)
            let sixthChar = Base32.encode(fourthByte: fourthByte)
            let seventhChar = Base32.encode(fourthByte: fourthByte, fifthByte: fifthByte)
            let eightChar = Base32.encode(fifthByte: fifthByte)
            
            output.append(firstChar)
            output.append(secondChar)
            output.append(thirdChar)
            output.append(fourthChar)
            output.append(fifthChar)
            output.append(sixthChar)
            output.append(seventhChar)
            output.append(eightChar)
        }
        
        return String(decoding: output, as: Unicode.UTF8.self)
    }
    
    private static func encode(firstByte: UInt8) -> UInt8 {
        let index = firstByte >> 3
        return alphabet[Int(index)]
    }
    
    private static func encode(firstByte: UInt8, secondByte: UInt8?) -> UInt8 {
        var index = (firstByte & 0b00000111) << 2
        
        if let secondByte = secondByte {
            index |= (secondByte & 0b11000000) >> 6
        }

        return alphabet[Int(index)]
    }
    
    private static func encode(secondByte: UInt8?) -> UInt8 {
        guard let secondByte = secondByte else {
            return Base32.encodePaddingCharacter
        }
        
        let index = (secondByte & 0b00111110) >> 1
        return alphabet[Int(index)]
    }
    
    private static func encode(secondByte: UInt8?, thirdByte: UInt8?) -> UInt8 {
        guard let secondByte = secondByte else {
            return Base32.encodePaddingCharacter
        }
        
        var index = (secondByte & 0b00000001) << 4
        
        if let thirdByte = thirdByte {
            index |= (thirdByte & 0b11110000) >> 4
        }
        
        return alphabet[Int(index)]
    }
    
    private static func encode(thirdByte: UInt8?, fourthByte: UInt8?) -> UInt8 {
        guard let thirdByte = thirdByte else {
            return Base32.encodePaddingCharacter
        }
        
        var index = (thirdByte & 0b00001111) << 1
        
        if let fourthByte = fourthByte {
            index |= (fourthByte & 0b10000000) >> 7
        }
        
        return alphabet[Int(index)]
    }
    
    private static func encode(fourthByte: UInt8?) -> UInt8 {
        guard let fourthByte = fourthByte else {
            return Base32.encodePaddingCharacter
        }
        
        let index = (fourthByte & 0b01111100) >> 2
        return alphabet[Int(index)]
    }
    
    private static func encode(fourthByte: UInt8?, fifthByte: UInt8?) -> UInt8 {
        guard let fourthByte = fourthByte else {
            return Base32.encodePaddingCharacter
        }
        
        var index = (fourthByte & 0b00000011) << 3
        
        if let fifthByte = fifthByte {
            index |= (fifthByte & 0b11100000) >> 5
        }
        
        return alphabet[Int(index)]
    }
    
    private static func encode(fifthByte: UInt8?) -> UInt8 {
        guard let fifthByte = fifthByte else {
            return Base32.encodePaddingCharacter
        }
        
        let index = fifthByte & 0b00011111
        return alphabet[Int(index)]
    }
}

// MARK: Decoding (Private)
extension Base32 {
    
    private static func decode<Buffer: Collection>(bytes: Buffer) throws -> String where Buffer.Element == UInt8 {
        let characterCount = bytes.count
        let inputBlocks = characterCount / 8
        let blocksWithoutPadding = inputBlocks - 1
        
        var output = [UInt8]()
        var input = bytes.makeIterator()
        
        for _ in 0..<blocksWithoutPadding {
            let firstValue = try input.nextValue()
            let secondValue = try input.nextValue()
            let thirdValue = try input.nextValue()
            let fourthValue = try input.nextValue()
            let fifthValue = try input.nextValue()
            let sixthValue = try input.nextValue()
            let seventhValue = try input.nextValue()
            let eightValue = try input.nextValue()
            
            output.append((firstValue << 3) | (secondValue >> 2))
            output.append((secondValue << 6) | (thirdValue << 1) | (fourthValue >> 4))
            output.append((fourthValue << 4) | (fifthValue >> 1))
            output.append((fifthValue << 7) | (sixthValue << 2) | (seventhValue >> 3))
            output.append((seventhValue << 5) | eightValue)
        }
        
        let firstByte = try input.nextValue()
        let secondByte = try input.nextValue()
        
        let value = (firstByte << 3) | (secondByte >> 2)
        output.append(value)
        
        let thirdByte = input.nextValueOrEmpty()
        let fourthByte = input.nextValueOrEmpty()
        
        if thirdByte != nil && fourthByte != nil {
            let value = (secondByte << 6) | (thirdByte! << 1) | (fourthByte! >> 4)
            output.append(value)
        }
        
        let fifthByte = input.nextValueOrEmpty()
        
        if fifthByte != nil {
            let value = (fourthByte! << 4) | (fifthByte! >> 1)
            output.append(value)
        }
        
        let sixthByte = input.nextValueOrEmpty()
        let seventhByte = input.nextValueOrEmpty()
        
        if sixthByte != nil && seventhByte != nil {
            let value = (fifthByte! << 7) | (sixthByte! << 2) | (seventhByte! >> 3)
            output.append(value)
        }
        
        let eightByte = input.nextValueOrEmpty()
        if eightByte != nil {
            let value = (seventhByte! << 5) | eightByte!
            output.append(value)
        }
        
        return String(decoding: output, as: Unicode.UTF8.self)
    }
}

extension IteratorProtocol where Self.Element == UInt8 {

    mutating func nextValue() throws -> UInt8 {
        let ascii = self.next()! // TODO: Refactor to not force-unwrap
        let value = Base32.alphabetDecodeTable[Int(ascii)]
        
        if value < 31 {
            return value
        }
        
        throw Base32.DecodingError.invalidCharacter([Character.init(Unicode.Scalar.init(ascii))])
    }
    
    mutating func nextValueOrEmpty() -> UInt8? {
        let ascii = self.next()! // TODO: Refactor to not force-unwrap
        if ascii == Base32.encodePaddingCharacter {
            return nil
        }
        
        let value = Base32.alphabetDecodeTable[Int(ascii)]
        
        if value < 31 {
            return value
        }
        
        return 255
    }
}
