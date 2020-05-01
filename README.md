# Base32Kit

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/0e2eb40e27ca4751a39ae31ff66a9dbb)](https://app.codacy.com/manual/jenslauterbach/Base32Kit?utm_source=github.com&utm_medium=referral&utm_content=jenslauterbach/Base32Kit&utm_campaign=Badge_Grade_Dashboard)
[![Swift 5.0 | 5.1 | 5.2](https://img.shields.io/badge/Swift-5.0%20%7C%C2%A05.1%20%7C%C2%A05.2-blue.svg)](https://swift.org)
![CI](https://github.com/jenslauterbach/Base32Kit/workflows/Build%20and%20Test/badge.svg)

> Disclaimer: This library is in its early development phase and should not yet be used in production. All the code in this repository might change, including its APIs. This library is not very well optimised. If you are looking for the absolute best performance this library is probably not for you.

Base32Kit is a simple _pure_ Swift Library for the Base32 encoding as defined by [RFC 4648](https://tools.ietf.org/html/rfc4648) that is implemented _without_ Apples Foundation framework.

API reference documentation is available at https://jenslauterbach.github.io/Base32Kit/

## Table of Contents

- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
- [Usage](#usage)
  - [Encoding](#encoding)
  - [Decoding](#decoding)
- [Design Goals](#design-goals)
- [Alternatives](#alternatives)
- [Versioning](#versioning)
- [Authors](#authors)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Installation

[(Back to top)](#table-of-contents)

### Swift Package Manager

```
// swift-tools-version:5.2
import PackageDescription

let package = Package(
    dependencies: [
        .package(url: "https://github.com/jenslauterbach/Base32Kit.git", from: "0.2.0"),
    ]
)
```

## Usage

### Encoding

```Swift
import Base32Kit

let encoded = Base32.encode(string: "foobar")
print(encoded) // prints MZXW6YTBOI======
```

### Decoding

All `decode*` methods can throw an error. In general you have two options of dealing with this. If you are not interested in the error and just need to decode the value or do "nothing", you can use a simple `try?` statement:

```Swift
import Base32Kit

if let decoded = try? Base32.decode(string: "MZXW6YTBOI======") {
    print(decoded) // prints "foobar"
}
```

If you want to handle any possible error in a more generlised way, you can use the following simple `do-catch` statement:

```Swift
import Base32Kit

do {
    let decoded = try Base32.decode(string: "MZXW6YTBOI======")
    print(decoded) // prints "foobar"
} catch {
    print("Error!")
}
```

The above code does not allow to handle all the different errors that may be thrown separately. To handle errors separately, you can use an extended version of the above `do-catch` statement:

```Swift
import Base32Kit

do {
    let decoded = try Base32.decode(string: "MZXW6YTBOI======")
    print(decoded) // prints "foobar"
} catch Base32.DecodingError.invalidLength {
    print("Encoded string has invalid length!")
} catch Base32.DecodingError.invalidPaddingCharacters {
    print("Encoded string uses illegal padding characters!")
} catch Base32.DecodingError.invalidCharacter(let illegalCharacters) {
    print("Encoded string contained the following illegal characters: \(illegalCharacters)")
} catch Base32.DecodingError.missingCharacter {
    print("During decoding there was an unexpected missing character!")
} catch {
    print("Error!")
}
```

## Design Goals

[(Back to top)](#table-of-contents)

The primary design goals of this Swift package are:

1. 100% RFC 4648 compliance.
2. Cross-platform (run everywhere where Swift runs).
2. The code is easy to read and understand.

Furthermore, we try to create a comprehensive test suite to verify the package with a big variety of test data on all supported platforms.

## Alternatives

[(Back to top)](#table-of-contents)

- [Base32](https://github.com/norio-nomura/Base32) by [Norio Nomura](https://github.com/norio-nomura)
- [Base32](https://github.com/std-swift/Base32) by [std-swift](https://github.com/std-swift)

## Versioning

[(Back to top)](#table-of-contents)

We use SemVer for versioning. For the versions available, see the [releases](https://github.com/jenslauterbach/Base32Kit/releases) page.

## Authors

[(Back to top)](#table-of-contents)

* Jens Lauterbach - Main author - (@jenslauterbach)

## License

[(Back to top)](#table-of-contents)

This project is licensed under the Apache 2.0 License - see the [LICENSE](https://github.com/jenslauterbach/Base32Kit/blob/master/LICENSE) file for details.

## Acknowledgments

[(Back to top)](#table-of-contents)

* [Fabian Fett](https://github.com/fabianfett) - For his inspiring [Base64Kit](https://github.com/fabianfett/swift-base64-kit) implementation
