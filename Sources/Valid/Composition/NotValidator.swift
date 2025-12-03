/// A validator that negates another validator.
///
/// The validation succeeds only if the wrapped validator fails.
public struct NotValidator<Wrapped: Validator>: Validator, Sendable {
    public typealias Value = Wrapped.Value

    private let validator: Wrapped
    private let error: ValidError

    /**
     Creates a NOT validator from a validator and error.

     - Parameters:
       - validator: The validator to negate.
       - error: The error to use when validation fails.
     */
    public init(validator: Wrapped, error: ValidError) {
        self.validator = validator
        self.error = error
    }

    public func validate(_ value: Value) -> ValidationResult {
        let result = validator.validate(value)
        return result.isValid ? .invalid([error]) : .valid
    }
}
