/// A protocol for types that can validate themselves.
///
/// Implement this protocol to provide validation logic for your custom types.
public protocol Validatable: Sendable {
    /**
     Validates this instance.

     - Returns: A validation result indicating success or failure.
     */
    func validate() -> ValidationResult
}

extension Validatable {
    /// Returns `true` if this instance is valid.
    public var isValid: Bool {
        validate().isValid
    }

    /// Returns the validation errors for this instance.
    public var validationErrors: [ValidError] {
        validate().errors
    }

    /**
     Validates this instance and throws if validation fails.

     - Throws: The first validation error if validation fails.
     */
    public func validateOrThrow() throws {
        let result = validate()
        guard case .invalid(let errors) = result, let firstError = errors.first else {
            return
        }
        throw firstError
    }
}

extension Validatable {
    /**
     Creates a validator for this type.

     - Returns: A validator that calls the instance's validate method.
     */
    public static func validator() -> AnyValidator<Self> {
        AnyValidator { instance in
            instance.validate()
        }
    }
}
