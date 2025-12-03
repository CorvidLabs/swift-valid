/// The result of a validation operation.
public enum ValidationResult: Sendable, Hashable {
    /// Validation succeeded.
    case valid

    /// Validation failed with one or more errors.
    case invalid([ValidError])

    /// Returns `true` if the validation succeeded.
    public var isValid: Bool {
        if case .valid = self {
            return true
        }
        return false
    }

    /// Returns `true` if the validation failed.
    public var isInvalid: Bool {
        !isValid
    }

    /// Returns the validation errors, or an empty array if valid.
    public var errors: [ValidError] {
        guard case .invalid(let errors) = self else {
            return []
        }
        return errors
    }

    /**
     Combines two validation results using logical AND.

     - Parameter other: The other validation result.
     - Returns: A combined result that is valid only if both are valid.
     */
    public func and(_ other: ValidationResult) -> ValidationResult {
        switch (self, other) {
        case (.valid, .valid):
            return .valid
        case (.invalid(let errors1), .invalid(let errors2)):
            return .invalid(errors1 + errors2)
        case (.invalid(let errors), .valid), (.valid, .invalid(let errors)):
            return .invalid(errors)
        }
    }

    /**
     Combines two validation results using logical OR.

     - Parameter other: The other validation result.
     - Returns: A combined result that is valid if either is valid.
     */
    public func or(_ other: ValidationResult) -> ValidationResult {
        switch (self, other) {
        case (.valid, _), (_, .valid):
            return .valid
        case (.invalid(let errors1), .invalid(let errors2)):
            return .invalid(errors1 + errors2)
        }
    }
}

extension ValidationResult {
    /**
     Creates a validation result from a boolean condition.

     - Parameters:
       - condition: The condition to evaluate.
       - error: The error to use if the condition is false.
     - Returns: A validation result.
     */
    public static func from(
        _ condition: Bool,
        error: ValidError
    ) -> ValidationResult {
        condition ? .valid : .invalid([error])
    }

    /**
     Creates a validation result from a boolean condition.

     - Parameters:
       - condition: The condition to evaluate.
       - message: The error message if the condition is false.
     - Returns: A validation result.
     */
    public static func from(
        _ condition: Bool,
        message: String
    ) -> ValidationResult {
        from(condition, error: ValidError(message: message))
    }
}
