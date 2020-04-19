# Base32Kit

> :warning: Disclaimer: This library is in its early development phase and should not yet be used in production. All the code in this repository might change, including its APIs.

Base32Kit is a simple _pure_ Swift Library for the Base32 encoding as defined by [RFC 4648](https://tools.ietf.org/html/rfc4648).

The main goals of this library are:

1. RFC 4648 compliance
2. Easy to read and understand
3. Well tested
4. Cross-platform (run everywhere where Swift runs)

This library is not very well optimised. If you are looking for the absolute best performance this library is probably not for you.

## Table of Contents

- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
- [Usage](#usage)
  - [Encoding](#encoding)
  - [Decoding](#decoding)
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
        .package(url: "https://github.com/jenslauterbach/Base32Kit.git", from: "0.1.0"),
    ]
)
```

## Usage

### Encoding

```Swift
import Base32Kit

let encoded = Base32.decode(string: "foobar")
print(encoded) // prints MZXW6YTBOI======
```

### Decoding

```Swift
import Base32Kit

let decoded = Base32.decode(string: "MZXW6YTBOI======")
print(decoded) // prints foobar
```

## Alternatives

[(Back to top)](#table-of-contents)

## Versioning

[(Back to top)](#table-of-contents)

We use SemVer for versioning. For the versions available, see the [tags on this repository]().

## Authors

[(Back to top)](#table-of-contents)

* Jens Lauterbach - Main author - (@jenslauterbach)

## License

[(Back to top)](#table-of-contents)

This project is licensed under the Apache 2.0 License - see the LICENSE file for details.

## Acknowledgments

[(Back to top)](#table-of-contents)

* [Fabian Fett](https://github.com/fabianfett) - For his inspiring [Base64Kit](https://github.com/fabianfett/swift-base64-kit) implementation
