extension Base32 {
    
    static let encodePaddingCharacter: UInt8 = UInt8(ascii: "=")
    
    static let alphabet: [UInt8] = [
        UInt8(ascii: "A"), // 0
        UInt8(ascii: "B"), // 1
        UInt8(ascii: "C"), // 2
        UInt8(ascii: "D"), // 3
        UInt8(ascii: "E"), // 4
        UInt8(ascii: "F"), // 5
        UInt8(ascii: "G"), // 6
        UInt8(ascii: "H"), // 7
        UInt8(ascii: "I"), // 8
        UInt8(ascii: "J"), // 9
        UInt8(ascii: "K"), // 10
        UInt8(ascii: "L"), // 11
        UInt8(ascii: "M"), // 12
        UInt8(ascii: "N"), // 13
        UInt8(ascii: "O"), // 14
        UInt8(ascii: "P"), // 15
        UInt8(ascii: "Q"), // 16
        UInt8(ascii: "R"), // 17
        UInt8(ascii: "S"), // 18
        UInt8(ascii: "T"), // 19
        UInt8(ascii: "U"), // 20
        UInt8(ascii: "V"), // 21
        UInt8(ascii: "W"), // 22
        UInt8(ascii: "X"), // 23
        UInt8(ascii: "Y"), // 24
        UInt8(ascii: "Z"), // 25
        UInt8(ascii: "2"), // 26
        UInt8(ascii: "3"), // 27
        UInt8(ascii: "4"), // 28
        UInt8(ascii: "5"), // 29
        UInt8(ascii: "6"), // 30
        UInt8(ascii: "7")  // 31
    ]
}
