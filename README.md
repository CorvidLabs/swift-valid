# SwiftValid

[![macOS](https://img.shields.io/github/actions/workflow/status/CorvidLabs/swift-valid/macOS.yml?label=macOS&branch=main)](https://github.com/CorvidLabs/swift-valid/actions/workflows/macOS.yml)
[![Ubuntu](https://img.shields.io/github/actions/workflow/status/CorvidLabs/swift-valid/ubuntu.yml?label=Ubuntu&branch=main)](https://github.com/CorvidLabs/swift-valid/actions/workflows/ubuntu.yml)
[![License](https://img.shields.io/github/license/CorvidLabs/swift-valid)](https://github.com/CorvidLabs/swift-valid/blob/main/LICENSE)
[![Version](https://img.shields.io/github/v/release/CorvidLabs/swift-valid)](https://github.com/CorvidLabs/swift-valid/releases)

A modern, composable validation library for Swift 6 with strict concurrency support.

## Features

- **Protocol-Oriented**: Built around the `Validator` protocol for maximum composability
- **Type-Safe**: Leverage Swift's type system to catch errors at compile time
- **Composable**: Combine validators using `and`, `or`, and `not` operators
- **Swift 6 Ready**: Full support for Swift 6 with strict concurrency
- **Sendable**: All public types conform to `Sendable` for safe concurrent usage
- **Zero Dependencies**: No external dependencies except swift-docc-plugin
- **Comprehensive**: Validators for strings, numbers, collections, and custom types
- **Schema Validation**: Result builder DSL for validating complex objects

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/0xLeif/swift-valid.git", from: "0.1.0")
]
```

Then add `Valid` to your target dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Valid", package: "swift-valid")
        ]
    )
]
```

## Quick Start

### Basic Validation

```swift
import Valid

// String validation
let emailValidator = EmailValidator()
let result = emailValidator.validate("user@example.com")

if result.isValid {
    print("Valid email!")
} else {
    print("Errors: \(result.errors)")
}

// Numeric validation
let ageValidator = RangeValidator(range: 18...120)
let isAdult = ageValidator.isValid(25) // true
```

### Composing Validators

```swift
// Combine validators with logical operators
let usernameValidator = LengthValidator(range: 3...20)
    .and(NotEmptyValidator())
    .and(PatternValidator(pattern: "^[a-zA-Z0-9_]+$"))

// Or create alternatives
let passwordValidator = LengthValidator(range: 8...128)
    .or(LengthValidator(range: 12...64).and(ContainsValidator(substring: "@")))
```

### Schema Validation

```swift
struct User: Sendable {
    let username: String
    let email: String
    let age: Int
}

let userValidator = Schema<User>.build {
    Schema.property(\User.username, fieldName: "username", validator: LengthValidator(range: 3...20))
    Schema.property(\User.email, fieldName: "email", validator: EmailValidator())
    Schema.property(\User.age, fieldName: "age", validator: RangeValidator(range: 18...120))
}

let user = User(username: "johndoe", email: "john@example.com", age: 25)
let result = userValidator.validate(user)
```

### Self-Validating Types

```swift
struct Product: Validatable, Sendable {
    let name: String
    let price: Double
    let tags: [String]

    func validate() -> ValidationResult {
        Schema<Product>.build {
            Schema.property(\Product.name, fieldName: "name", validator: NotEmptyValidator())
            Schema.property(\Product.price, fieldName: "price", validator: PositiveValidator<Double>())
            Schema.property(\Product.tags, fieldName: "tags", validator: CountValidator<[String]>.minimum(1))
        }
        .validate(self)
    }
}

let product = Product(name: "Widget", price: 19.99, tags: ["sale"])
if product.isValid {
    print("Product is valid!")
}
```

## Available Validators

### String Validators

- `LengthValidator`: Validate string length
- `NotEmptyValidator`: Ensure string is not empty
- `NotBlankValidator`: Ensure string contains non-whitespace characters
- `EmailValidator`: Validate email format
- `PatternValidator`: Match against regex patterns
- `ContainsValidator`: Check for substring presence
- `PrefixValidator`: Validate string prefix
- `SuffixValidator`: Validate string suffix

### Numeric Validators

- `RangeValidator`: Validate value is within a range
- `MinimumValidator`: Validate minimum value (inclusive or exclusive)
- `MaximumValidator`: Validate maximum value (inclusive or exclusive)
- `PositiveValidator`: Ensure value is positive
- `NegativeValidator`: Ensure value is negative
- `EvenValidator`: Validate even integers
- `OddValidator`: Validate odd integers
- `MultipleOfValidator`: Check if value is a multiple of another

### Collection Validators

- `CountValidator`: Validate collection count
- `CollectionNotEmptyValidator`: Ensure collection is not empty
- `EachValidator`: Validate each element in a collection
- `UniqueValidator`: Ensure all elements are unique
- `ContainsElementValidator`: Check if collection contains an element
- `AllSatisfyValidator`: Ensure all elements satisfy a predicate
- `SortedValidator`: Validate collection is sorted

### Composition Validators

- `AndValidator`: Combine validators with logical AND
- `OrValidator`: Combine validators with logical OR
- `NotValidator`: Negate a validator
- `AnyValidator`: Type-erased validator

## Advanced Usage

### Custom Validators

Create custom validators by conforming to the `Validator` protocol:

```swift
struct IPAddressValidator: Validator, Sendable {
    func validate(_ value: String) -> ValidationResult {
        let pattern = #"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(value.startIndex..., in: value)
        let matches = regex?.firstMatch(in: value, range: range) != nil

        return .from(matches, message: "Invalid IP address format")
    }
}
```

### Functional Validators

Use `AnyValidator` for inline validation logic:

```swift
let evenNumberValidator = AnyValidator<Int>.predicate(
    message: "Number must be even"
) { $0.isMultiple(of: 2) }
```

### Error Handling

```swift
// Get all errors
let result = validator.validate(value)
if case .invalid(let errors) = result {
    errors.forEach { error in
        print("\(error.message)")
        if let field = error.context["field"] {
            print("Field: \(field)")
        }
    }
}

// Throw on invalid
do {
    try validator.validateOrThrow(value)
} catch let error as ValidError {
    print("Validation failed: \(error.message)")
}
```

## Design Philosophy

Valid follows the distinctive 0xLeif Swift development patterns:

- **Protocol-Oriented**: Favor protocols and protocol extensions over inheritance
- **Functional**: Embrace map, flatMap, and other functional patterns
- **Modern Swift**: Leverage async/await, actors, property wrappers, and result builders
- **Type Safety**: Use the type system to prevent errors at compile time
- **Clarity**: Write code that is immediately understandable
- **Composition**: Break down complex problems into small, composable pieces

## Platform Support

- iOS 16.0+
- macOS 13.0+
- tvOS 16.0+
- watchOS 9.0+
- visionOS 1.0+

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
