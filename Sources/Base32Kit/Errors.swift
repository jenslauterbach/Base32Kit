extension Base32 {
    
    public enum DecodingError: Error, Equatable {
        
        /// The `String` to decode has invalid length. A string that should be decoded should have a length that is a multiple of 8
        /// (e.g. 8 characters, 16, 24 ... 80, 96, etc.)
        case invalidLength
        
        /// Thrown when the encoded `String` contains invalid characters.
        ///
        /// Base 32 Encoding only supports a very limited alphabet to which input data can be encoded to. If a given _encoded_ `String` contains characters that
        /// are not part of this alphabet, this error is thrown.
        ///
        /// The error contains the invalid `Character`.
        case invalidCharacter([Character])
        
        case invalidPaddingCharacters
    }
}
