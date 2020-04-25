extension Base32 {
    
    /// Errors that can be thrown during decoding of a Base 32 encoded string.
    enum DecodingError: Error, Equatable {
        
        /// The `String` to decode has invalid length. A string that should be decoded should have a length that is a multiple of 8
        /// (e.g. 8 characters, 16, 24 ... 80, 96, etc.)
        case invalidLength
        
        /// Thrown when the encoded `String` contains invalid characters.
        ///
        /// Base 32 Encoding only supports a very limited alphabet to which input data can be encoded to. If a given _encoded_ `String` contains characters
        /// that are not part of this alphabet, this error is thrown.
        ///
        /// The error contains an array of all the invalid `Character`s found.
        case invalidCharacter([Character])
        
        /// Thrown when the encoded  `String` contains one or more invalid padding characters (`=`).
        ///
        /// Padding characters are only allowed at the end of the encoded string and no other character is allowed to follow.
        ///
        /// Examples:
        /// - OK: `"MZXQ===="`
        /// - Not OK: `"M=XQ===="`
        case invalidPaddingCharacters
        
        /// Thrown when the encoded `String` decodes to a result that is illegal.
        case invalidEncodedString
        
        /// Thrown when reading the encoded `String` and no character can be found at position one or two even though it should exist.
        case missingCharacter
    }
}
