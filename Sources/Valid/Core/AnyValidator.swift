/// A type-erased validator.
///
/// Use `AnyValidator` to hide the specific type of a validator while preserving
/// its validation behavior.
public struct AnyValidator<Value>: Validator, Sendable {
    private let validateClosure: @Sendable (Value) -> ValidationResult

    /// Creates a type-erased validator from any validator.
    ///
    /// - Parameter validator: The validator to type-erase.
    public init<V: Validator>(_ validator: V) where V.Value == Value {
        self.validateClosure = validator.validate
    }

    /// Creates a type-erased validator from a validation closure.
    ///
    /// - Parameter validate: The validation closure.
    public init(validate: @escaping @Sendable (Value) -> ValidationResult) {
        self.validateClosure = validate
    }

    public func validate(_ value: Value) -> ValidationResult {
        validateClosure(value)
    }
}

extension AnyValidator {
    /// Creates a validator that always succeeds.
    public static var valid: AnyValidator<Value> {
        AnyValidator { _ in .valid }
    }

    /// Creates a validator that always fails with the given error.
    ///
    /// - Parameter error: The error to use.
    public static func invalid(error: ValidError) -> AnyValidator<Value> {
        AnyValidator { _ in .invalid([error]) }
    }

    /// Creates a validator that always fails with the given message.
    ///
    /// - Parameter message: The error message.
    public static func invalid(message: String) -> AnyValidator<Value> {
        invalid(error: ValidError(message: message))
    }
}

extension AnyValidator {
    /// Creates a validator from a boolean predicate.
    ///
    /// - Parameters:
    ///   - error: The error to use when validation fails.
    ///   - predicate: The predicate to evaluate.
    public static func predicate(
        error: ValidError,
        _ predicate: @escaping @Sendable (Value) -> Bool
    ) -> AnyValidator<Value> {
        AnyValidator { value in
            .from(predicate(value), error: error)
        }
    }

    /// Creates a validator from a boolean predicate.
    ///
    /// - Parameters:
    ///   - message: The error message when validation fails.
    ///   - predicate: The predicate to evaluate.
    public static func predicate(
        message: String,
        _ predicate: @escaping @Sendable (Value) -> Bool
    ) -> AnyValidator<Value> {
        self.predicate(
            error: ValidError(message: message),
            predicate
        )
    }
}
