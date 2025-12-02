import Foundation

// MARK: - Range Validator

/// Validates that a comparable value falls within a specified range.
public struct RangeValidator<Value: Comparable & Sendable>: Validator, Sendable {
    private let range: ClosedRange<Value>

    /// Creates a range validator.
    ///
    /// - Parameter range: The acceptable range.
    public init(range: ClosedRange<Value>) {
        self.range = range
    }

    public func validate(_ value: Value) -> ValidationResult {
        guard range.contains(value) else {
            return .invalid([
                ValidError(message: "Value must be between \(range.lowerBound) and \(range.upperBound)")
            ])
        }
        return .valid
    }
}

// MARK: - Minimum Validator

/// Validates that a comparable value is at least a minimum value.
public struct MinimumValidator<Value: Comparable & Sendable>: Validator, Sendable {
    private let minimum: Value
    private let inclusive: Bool

    /// Creates a minimum validator.
    ///
    /// - Parameters:
    ///   - minimum: The minimum value.
    ///   - inclusive: Whether the minimum is inclusive.
    public init(minimum: Value, inclusive: Bool = true) {
        self.minimum = minimum
        self.inclusive = inclusive
    }

    public func validate(_ value: Value) -> ValidationResult {
        let isValid = inclusive ? value >= minimum : value > minimum
        let operator_ = inclusive ? ">=" : ">"

        return .from(
            isValid,
            message: "Value must be \(operator_) \(minimum)"
        )
    }
}

// MARK: - Maximum Validator

/// Validates that a comparable value is at most a maximum value.
public struct MaximumValidator<Value: Comparable & Sendable>: Validator, Sendable {
    private let maximum: Value
    private let inclusive: Bool

    /// Creates a maximum validator.
    ///
    /// - Parameters:
    ///   - maximum: The maximum value.
    ///   - inclusive: Whether the maximum is inclusive.
    public init(maximum: Value, inclusive: Bool = true) {
        self.maximum = maximum
        self.inclusive = inclusive
    }

    public func validate(_ value: Value) -> ValidationResult {
        let isValid = inclusive ? value <= maximum : value < maximum
        let operator_ = inclusive ? "<=" : "<"

        return .from(
            isValid,
            message: "Value must be \(operator_) \(maximum)"
        )
    }
}

// MARK: - Positive Validator

/// Validates that a numeric value is positive.
public struct PositiveValidator<Value: Numeric & Comparable & Sendable>: Validator, Sendable {
    private let strict: Bool

    /// Creates a positive validator.
    ///
    /// - Parameter strict: If true, zero is not considered positive.
    public init(strict: Bool = true) {
        self.strict = strict
    }

    public func validate(_ value: Value) -> ValidationResult {
        let isPositive = strict ? value > .zero : value >= .zero
        let message = strict ? "Value must be positive (> 0)" : "Value must be non-negative (>= 0)"

        return .from(isPositive, message: message)
    }
}

// MARK: - Negative Validator

/// Validates that a numeric value is negative.
public struct NegativeValidator<Value: Numeric & Comparable & Sendable>: Validator, Sendable {
    private let strict: Bool

    /// Creates a negative validator.
    ///
    /// - Parameter strict: If true, zero is not considered negative.
    public init(strict: Bool = true) {
        self.strict = strict
    }

    public func validate(_ value: Value) -> ValidationResult {
        let isNegative = strict ? value < .zero : value <= .zero
        let message = strict ? "Value must be negative (< 0)" : "Value must be non-positive (<= 0)"

        return .from(isNegative, message: message)
    }
}

// MARK: - Even Validator

/// Validates that an integer is even.
public struct EvenValidator<Value: BinaryInteger & Sendable>: Validator, Sendable {
    public init() {}

    public func validate(_ value: Value) -> ValidationResult {
        .from(value.isMultiple(of: 2), message: "Value must be even")
    }
}

// MARK: - Odd Validator

/// Validates that an integer is odd.
public struct OddValidator<Value: BinaryInteger & Sendable>: Validator, Sendable {
    public init() {}

    public func validate(_ value: Value) -> ValidationResult {
        .from(!value.isMultiple(of: 2), message: "Value must be odd")
    }
}

// MARK: - Multiple Of Validator

/// Validates that a value is a multiple of another value.
public struct MultipleOfValidator<Value: BinaryInteger & Sendable>: Validator, Sendable {
    private let divisor: Value

    /// Creates a multiple-of validator.
    ///
    /// - Parameter divisor: The divisor to check against.
    public init(divisor: Value) {
        self.divisor = divisor
    }

    public func validate(_ value: Value) -> ValidationResult {
        .from(
            value.isMultiple(of: divisor),
            message: "Value must be a multiple of \(divisor)"
        )
    }
}

// MARK: - Convenience Extensions

extension Validator where Value: Comparable & Sendable {
    /// Validates value is within a range.
    public static func range(_ range: ClosedRange<Value>) -> RangeValidator<Value> {
        RangeValidator(range: range)
    }

    /// Validates value is at least a minimum.
    public static func min(_ minimum: Value, inclusive: Bool = true) -> MinimumValidator<Value> {
        MinimumValidator(minimum: minimum, inclusive: inclusive)
    }

    /// Validates value is at most a maximum.
    public static func max(_ maximum: Value, inclusive: Bool = true) -> MaximumValidator<Value> {
        MaximumValidator(maximum: maximum, inclusive: inclusive)
    }
}

extension Validator where Value: Numeric & Comparable & Sendable {
    /// Validates value is positive.
    public static func positive(strict: Bool = true) -> PositiveValidator<Value> {
        PositiveValidator(strict: strict)
    }

    /// Validates value is negative.
    public static func negative(strict: Bool = true) -> NegativeValidator<Value> {
        NegativeValidator(strict: strict)
    }
}

extension Validator where Value: BinaryInteger & Sendable {
    /// Validates value is even.
    public static var even: EvenValidator<Value> {
        EvenValidator()
    }

    /// Validates value is odd.
    public static var odd: OddValidator<Value> {
        OddValidator()
    }

    /// Validates value is a multiple of another value.
    public static func multipleOf(_ divisor: Value) -> MultipleOfValidator<Value> {
        MultipleOfValidator(divisor: divisor)
    }
}
