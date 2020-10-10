public enum Alphabet {
    case standard
    case hex
}

extension Base32 {
    static let encodePaddingCharacter: UInt8 = UInt8(ascii: "=")

    static let encodingTables: [Alphabet: [UInt8]] = [
        .standard: base32,
        .hex: base32hex,
    ]

    static let base32: [UInt8] = [
        UInt8(ascii: "A"), //  0
        UInt8(ascii: "B"), //  1
        UInt8(ascii: "C"), //  2
        UInt8(ascii: "D"), //  3
        UInt8(ascii: "E"), //  4
        UInt8(ascii: "F"), //  5
        UInt8(ascii: "G"), //  6
        UInt8(ascii: "H"), //  7
        UInt8(ascii: "I"), //  8
        UInt8(ascii: "J"), //  9
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
        UInt8(ascii: "7"), // 31
    ]
}

extension Base32 {
    static let base32hex: [UInt8] = [
        UInt8(ascii: "0"), //  0
        UInt8(ascii: "1"), //  1
        UInt8(ascii: "2"), //  2
        UInt8(ascii: "3"), //  3
        UInt8(ascii: "4"), //  4
        UInt8(ascii: "5"), //  5
        UInt8(ascii: "6"), //  6
        UInt8(ascii: "7"), //  7
        UInt8(ascii: "8"), //  8
        UInt8(ascii: "9"), //  9
        UInt8(ascii: "A"), // 10
        UInt8(ascii: "B"), // 11
        UInt8(ascii: "C"), // 12
        UInt8(ascii: "D"), // 13
        UInt8(ascii: "E"), // 14
        UInt8(ascii: "F"), // 15
        UInt8(ascii: "G"), // 16
        UInt8(ascii: "H"), // 17
        UInt8(ascii: "I"), // 18
        UInt8(ascii: "J"), // 19
        UInt8(ascii: "K"), // 20
        UInt8(ascii: "L"), // 21
        UInt8(ascii: "M"), // 22
        UInt8(ascii: "N"), // 23
        UInt8(ascii: "O"), // 24
        UInt8(ascii: "P"), // 25
        UInt8(ascii: "Q"), // 26
        UInt8(ascii: "R"), // 27
        UInt8(ascii: "S"), // 28
        UInt8(ascii: "T"), // 29
        UInt8(ascii: "U"), // 30
        UInt8(ascii: "V"), // 31
    ]
}

extension Base32 {
    private static let __: UInt8 = 255

    static let decodingTables: [Alphabet: [UInt8]] = [
        .standard: decodeBase32,
        .hex: decodeBase32hex,
    ]

    static let decodeBase32: [UInt8] = [
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, 26, 27, 28, 29, 30, 31, __, __, __, __, __, __, __, __,
        __, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, __, __, __, __, __,
        __, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
    ]

    static let decodeBase32hex: [UInt8] = [
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, __, __, __, __, __, __,
        __, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
        25, 26, 27, 28, 29, 30, 31, __, __, __, __, __, __, __, __, __,
        __, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
        25, 26, 27, 28, 29, 30, 31, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
        __, __, __, __, __, __, __, __, __, __, __, __, __, __, __, __,
    ]
}
