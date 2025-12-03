/// A protocol for types that can validate values.
///
/// Validators are composable and can be combined using logical operators.
public protocol Validator<Value>: Sendable {
    /// The type of value being validated.
    associatedtype Value

    /**
     Validates the given value.

     - Parameter value: The value to validate.
     - Returns: A validation result indicating success or failure.
     */
    func validate(_ value: Value) -> ValidationResult
}

extension Validator {
    /**
     Combines this validator with another using logical AND.

     The resulting validator passes only if both validators pass.

     - Parameter other: The other validator to combine with.
     - Returns: A combined validator.
     */
    public func and<V: Validator>(_ other: V) -> AndValidator<Self, V> where V.Value == Value {
        AndValidator(first: self, second: other)
    }

    /**
     Combines this validator with another using logical OR.

     The resulting validator passes if either validator passes.

     - Parameter other: The other validator to combine with.
     - Returns: A combined validator.
     */
    public func or<V: Validator>(_ other: V) -> OrValidator<Self, V> where V.Value == Value {
        OrValidator(first: self, second: other)
    }

    /**
     Negates this validator.

     The resulting validator passes only if this validator fails.

     - Parameter error: The error to use when the negated validator fails.
     - Returns: A negated validator.
     */
    public func not(error: ValidError) -> NotValidator<Self> {
        NotValidator(validator: self, error: error)
    }

    /**
     Negates this validator.

     The resulting validator passes only if this validator fails.

     - Parameter message: The error message when the negated validator fails.
     - Returns: A negated validator.
     */
    public func not(message: String) -> NotValidator<Self> {
        not(error: ValidError(message: message))
    }

    /// Type-erases this validator.
    ///
    /// - Returns: A type-erased validator.
    public func eraseToAnyValidator() -> AnyValidator<Value> {
        AnyValidator(self)
    }
}

extension Validator {
    /**
     Validates a value and returns a boolean result.

     - Parameter value: The value to validate.
     - Returns: `true` if validation succeeds, `false` otherwise.
     */
    public func isValid(_ value: Value) -> Bool {
        validate(value).isValid
    }

    /**
     Validates a value and throws if validation fails.

     - Parameter value: The value to validate.
     - Throws: The first validation error if validation fails.
     */
    public func validateOrThrow(_ value: Value) throws {
        let result = validate(value)
        guard case .invalid(let errors) = result, let firstError = errors.first else {
            return
        }
        throw firstError
    }
}
