import Foundation

// MARK: - Count Validator

/// Validates that a collection's count falls within a specified range.
public struct CountValidator<C: Collection & Sendable>: Validator, Sendable {
    public typealias Value = C

    private let range: ClosedRange<Int>

    /// Creates a count validator.
    ///
    /// - Parameter range: The acceptable count range.
    public init(range: ClosedRange<Int>) {
        self.range = range
    }

    public func validate(_ value: C) -> ValidationResult {
        let count = value.count
        guard range.contains(count) else {
            return .invalid([
                ValidError(
                    message: "Count must be between \(range.lowerBound) and \(range.upperBound), got \(count)"
                )
            ])
        }
        return .valid
    }
}

extension CountValidator {
    /// Creates a validator for exact count.
    ///
    /// - Parameter count: The required count.
    public static func exactly(_ count: Int) -> CountValidator<C> {
        CountValidator(range: count...count)
    }

    /// Creates a validator for minimum count.
    ///
    /// - Parameter minimum: The minimum count.
    public static func minimum(_ minimum: Int) -> CountValidator<C> {
        CountValidator(range: minimum...Int.max)
    }

    /// Creates a validator for maximum count.
    ///
    /// - Parameter maximum: The maximum count.
    public static func maximum(_ maximum: Int) -> CountValidator<C> {
        CountValidator(range: 0...maximum)
    }
}

// MARK: - Collection Not Empty Validator

/// Validates that a collection is not empty.
public struct CollectionNotEmptyValidator<C: Collection & Sendable>: Validator, Sendable {
    public typealias Value = C

    public init() {}

    public func validate(_ value: C) -> ValidationResult {
        .from(!value.isEmpty, message: "Collection must not be empty")
    }
}

// MARK: - Each Validator

/// Validates that each element in a collection satisfies a validator.
public struct EachValidator<C: Collection & Sendable, V: Validator>: Validator, Sendable
where C.Element == V.Value {
    public typealias Value = C

    private let elementValidator: V

    /// Creates an each validator.
    ///
    /// - Parameter elementValidator: The validator to apply to each element.
    public init(elementValidator: V) {
        self.elementValidator = elementValidator
    }

    public func validate(_ value: C) -> ValidationResult {
        let results = value.enumerated().map { index, element in
            let result = elementValidator.validate(element)
            if case .invalid(let errors) = result {
                return ValidationResult.invalid(
                    errors.map { error in
                        ValidError(
                            message: error.message,
                            context: error.context.merging(["index": String(index)]) { _, new in new }
                        )
                    }
                )
            }
            return result
        }

        return results.reduce(.valid) { $0.and($1) }
    }
}

// MARK: - Unique Validator

/// Validates that all elements in a collection are unique.
public struct UniqueValidator<C: Collection & Sendable>: Validator, Sendable
where C.Element: Hashable {
    public typealias Value = C

    public init() {}

    public func validate(_ value: C) -> ValidationResult {
        var seen = Set<C.Element>()
        var duplicates = Set<C.Element>()

        for element in value {
            if seen.contains(element) {
                duplicates.insert(element)
            } else {
                seen.insert(element)
            }
        }

        if duplicates.isEmpty {
            return .valid
        }

        let duplicatesList = duplicates.map { "\($0)" }.joined(separator: ", ")
        return .invalid([
            ValidError(message: "Collection contains duplicate elements: \(duplicatesList)")
        ])
    }
}

// MARK: - Contains Element Validator

/// Validates that a collection contains a specific element.
public struct ContainsElementValidator<C: Collection & Sendable>: Validator
where C.Element: Equatable & Sendable {
    public typealias Value = C

    private let element: C.Element

    /// Creates a contains element validator.
    ///
    /// - Parameter element: The element to search for.
    public init(element: C.Element) {
        self.element = element
    }

    public func validate(_ value: C) -> ValidationResult {
        .from(
            value.contains(element),
            message: "Collection must contain element: \(element)"
        )
    }
}

extension ContainsElementValidator: @unchecked Sendable where C: Sendable, C.Element: Sendable {}

// MARK: - All Satisfy Validator

/// Validates that all elements in a collection satisfy a predicate.
public struct AllSatisfyValidator<C: Collection & Sendable>: Validator, Sendable {
    public typealias Value = C

    private let predicate: @Sendable (C.Element) -> Bool
    private let message: String

    /// Creates an all-satisfy validator.
    ///
    /// - Parameters:
    ///   - message: The error message when validation fails.
    ///   - predicate: The predicate each element must satisfy.
    public init(
        message: String = "Not all elements satisfy the condition",
        predicate: @escaping @Sendable (C.Element) -> Bool
    ) {
        self.predicate = predicate
        self.message = message
    }

    public func validate(_ value: C) -> ValidationResult {
        .from(value.allSatisfy(predicate), message: message)
    }
}

// MARK: - Sorted Validator

/// Validates that a collection is sorted.
public struct SortedValidator<C: Collection & Sendable>: Validator, Sendable
where C.Element: Comparable {
    public typealias Value = C

    private let order: SortOrder

    public enum SortOrder: Sendable {
        case ascending
        case descending
    }

    /// Creates a sorted validator.
    ///
    /// - Parameter order: The expected sort order.
    public init(order: SortOrder = .ascending) {
        self.order = order
    }

    public func validate(_ value: C) -> ValidationResult {
        guard !value.isEmpty else {
            return .valid
        }

        let elements = Array(value)
        let isSorted: Bool

        switch order {
        case .ascending:
            isSorted = zip(elements, elements.dropFirst()).allSatisfy { $0 <= $1 }
        case .descending:
            isSorted = zip(elements, elements.dropFirst()).allSatisfy { $0 >= $1 }
        }

        let orderString = order == .ascending ? "ascending" : "descending"
        return .from(isSorted, message: "Collection must be sorted in \(orderString) order")
    }
}

// MARK: - Convenience Extensions

extension Validator where Value: Collection & Sendable {
    /// Validates collection count.
    public static func count(_ range: ClosedRange<Int>) -> CountValidator<Value> {
        CountValidator(range: range)
    }

    /// Validates exact collection count.
    public static func count(exactly: Int) -> CountValidator<Value> {
        CountValidator.exactly(exactly)
    }

    /// Validates minimum collection count.
    public static func count(minimum: Int) -> CountValidator<Value> {
        CountValidator.minimum(minimum)
    }

    /// Validates maximum collection count.
    public static func count(maximum: Int) -> CountValidator<Value> {
        CountValidator.maximum(maximum)
    }

    /// Validates collection is not empty.
    public static var notEmpty: CollectionNotEmptyValidator<Value> {
        CollectionNotEmptyValidator()
    }

    /// Validates each element in the collection.
    public static func each<V: Validator>(_ elementValidator: V) -> EachValidator<Value, V>
    where V.Value == Value.Element {
        EachValidator(elementValidator: elementValidator)
    }

    /// Validates all elements satisfy a condition.
    public static func allSatisfy(
        message: String = "Not all elements satisfy the condition",
        _ predicate: @escaping @Sendable (Value.Element) -> Bool
    ) -> AllSatisfyValidator<Value> {
        AllSatisfyValidator(message: message, predicate: predicate)
    }
}

extension Validator where Value: Collection & Sendable, Value.Element: Hashable {
    /// Validates all elements are unique.
    public static var unique: UniqueValidator<Value> {
        UniqueValidator()
    }
}

extension Validator where Value: Collection & Sendable, Value.Element: Equatable & Sendable {
    /// Validates collection contains an element.
    public static func contains(_ element: Value.Element) -> ContainsElementValidator<Value> {
        ContainsElementValidator(element: element)
    }
}

extension Validator where Value: Collection & Sendable, Value.Element: Comparable {
    /// Validates collection is sorted.
    public static func sorted(order: SortedValidator<Value>.SortOrder = .ascending) -> SortedValidator<Value> {
        SortedValidator(order: order)
    }
}
