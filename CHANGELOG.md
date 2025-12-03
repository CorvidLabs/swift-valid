# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-12-02

### Added
- Initial release of SwiftValid
- Core `Validator` protocol with full Swift 6 concurrency support
- `ValidationResult` enum with comprehensive error handling
- `ValidError` type with context support for detailed error reporting
- Composition validators: `AndValidator`, `OrValidator`, `NotValidator`
- Type-erased `AnyValidator` for flexibility
- String validators: `LengthValidator`, `NotEmptyValidator`, `NotBlankValidator`, `EmailValidator`, `PatternValidator`, `ContainsValidator`, `PrefixValidator`, `SuffixValidator`
- Numeric validators: `RangeValidator`, `MinimumValidator`, `MaximumValidator`, `PositiveValidator`, `NegativeValidator`, `EvenValidator`, `OddValidator`, `MultipleOfValidator`
- Collection validators: `CountValidator`, `CollectionNotEmptyValidator`, `EachValidator`, `UniqueValidator`, `ContainsElementValidator`, `AllSatisfyValidator`, `SortedValidator`
- Schema validation with `PropertyValidator` and `SchemaBuilder` result builder
- `Validatable` protocol for self-validating types
- Comprehensive test suite with 109 tests
- Full DocC documentation support
- CI/CD workflows for macOS and Linux
- DocC documentation deployment to GitHub Pages
