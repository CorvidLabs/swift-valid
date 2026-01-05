/**
 A validator that combines two validators using logical OR.

 The validation succeeds if either validator succeeds.
 */
public struct OrValidator<First: Validator, Second: Validator>: Validator, Sendable
where First.Value == Second.Value {
    public typealias Value = First.Value

    private let first: First
    private let second: Second

    /**
     Creates an OR validator from two validators.

     - Parameters:
       - first: The first validator.
       - second: The second validator.
     */
    public init(first: First, second: Second) {
        self.first = first
        self.second = second
    }

    public func validate(_ value: Value) -> ValidationResult {
        first.validate(value).or(second.validate(value))
    }
}

extension OrValidator {
    /**
     Chains another validator using OR.

     - Parameter other: The validator to chain.
     - Returns: A combined validator.
     */
    public func or<V: Validator>(_ other: V) -> OrValidator<Self, V> where V.Value == Value {
        OrValidator<Self, V>(first: self, second: other)
    }
}
