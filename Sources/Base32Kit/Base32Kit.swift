// MARK: Public API
struct Base32 {
    
    static func encode(string s: String) -> String {
        return encode(bytes: Array(s.utf8))
    }
    
    static func decode(string s: String) -> String {
        return decode(bytes: Array(s.utf8))
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
    
    private static func decode<Buffer: Collection>(bytes: Buffer) -> String where Buffer.Element == UInt8 {
        let characterCount = bytes.count
        
        guard characterCount > 0 else {
            return ""
        }
        
        guard characterCount % 8 == 0 else {
            return "length error" // TODO: Introduce proper error!
        }
        
        let inputBlocks = characterCount / 8
        let blocksWithoutPadding = inputBlocks - 1
        
        var output = [UInt8]()
        var input = bytes.makeIterator()
        
        for _ in 0..<blocksWithoutPadding {
            let firstValue = input.nextValue()
            let secondValue = input.nextValue()
            let thirdValue = input.nextValue()
            let fourthValue = input.nextValue()
            let fifthValue = input.nextValue()
            let sixthValue = input.nextValue()
            let seventhValue = input.nextValue()
            let eightValue = input.nextValue()
            
            output.append((firstValue << 3) | (secondValue >> 2))
            output.append((secondValue << 6) | (thirdValue << 1) | (fourthValue >> 4))
            output.append((fourthValue << 4) | (fifthValue >> 1))
            output.append((fifthValue << 7) | (sixthValue << 2) | (seventhValue >> 3))
            output.append((seventhValue << 5) | eightValue)
        }
        
        let firstByte = input.nextValue()
        let secondByte = input.nextValue()
        
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

    mutating func nextValue() -> UInt8 {
        let ascii = self.next()! // TODO: Refactor to not force-unwrap
        let value = Base32.alphabetDecodeTable[Int(ascii)]
        
        if value < 31 {
            return value
        }
        
        return 255
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
