/// A validator that combines two validators using logical AND.
///
/// The validation succeeds only if both validators succeed.
public struct AndValidator<First: Validator, Second: Validator>: Validator, Sendable
where First.Value == Second.Value {
    public typealias Value = First.Value

    private let first: First
    private let second: Second

    /// Creates an AND validator from two validators.
    ///
    /// - Parameters:
    ///   - first: The first validator.
    ///   - second: The second validator.
    public init(first: First, second: Second) {
        self.first = first
        self.second = second
    }

    public func validate(_ value: Value) -> ValidationResult {
        first.validate(value).and(second.validate(value))
    }
}

extension AndValidator {
    /// Chains another validator using AND.
    ///
    /// - Parameter other: The validator to chain.
    /// - Returns: A combined validator.
    public func and<V: Validator>(_ other: V) -> AndValidator<Self, V> where V.Value == Value {
        AndValidator<Self, V>(first: self, second: other)
    }
}
