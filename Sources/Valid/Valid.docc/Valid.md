# ``Valid``

A modern, composable validation library for Swift 6 with strict concurrency support.

## Overview

SwiftValid provides a protocol-oriented approach to validating data in Swift applications. Built with Swift 6 in mind, it offers full concurrency support and leverages the latest language features including result builders, property wrappers, and strict typing.

### Key Features

- **Protocol-Oriented**: Built around the ``Validator`` protocol for maximum composability
- **Type-Safe**: Leverage Swift's type system to catch errors at compile time
- **Composable**: Combine validators using logical operators (``Validator/and(_:)``, ``Validator/or(_:)``, ``Validator/not(message:)``)
- **Swift 6 Ready**: Full support for Swift 6 with strict concurrency
- **Sendable**: All public types conform to `Sendable` for safe concurrent usage
- **Zero Dependencies**: No external dependencies except swift-docc-plugin
- **Schema Validation**: Result builder DSL for validating complex objects

## Topics

### Essentials

- ``Validator``
- ``ValidationResult``
- ``ValidError``

### Composition

- ``AndValidator``
- ``OrValidator``
- ``NotValidator``
- ``AnyValidator``

### String Validation

- ``LengthValidator``
- ``NotEmptyValidator``
- ``NotBlankValidator``
- ``EmailValidator``
- ``PatternValidator``
- ``ContainsValidator``
- ``PrefixValidator``
- ``SuffixValidator``

### Numeric Validation

- ``RangeValidator``
- ``MinimumValidator``
- ``MaximumValidator``
- ``PositiveValidator``
- ``NegativeValidator``
- ``EvenValidator``
- ``OddValidator``
- ``MultipleOfValidator``

### Collection Validation

- ``CountValidator``
- ``CollectionNotEmptyValidator``
- ``EachValidator``
- ``UniqueValidator``
- ``ContainsElementValidator``
- ``AllSatisfyValidator``
- ``SortedValidator``

### Schema Validation

- ``Schema``
- ``SchemaBuilder``
- ``PropertyValidator``
- ``Validatable``
