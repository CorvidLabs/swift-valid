/// A validation error containing a descriptive message and optional context.
public struct ValidError: Error, Sendable, Hashable, CustomStringConvertible {
    /// The error message describing what failed validation.
    public let message: String

    /// Optional context about where or why the validation failed.
    public let context: [String: String]

    /// Creates a validation error with a message and optional context.
    ///
    /// - Parameters:
    ///   - message: The error message.
    ///   - context: Additional context information.
    public init(
        message: String,
        context: [String: String] = [:]
    ) {
        self.message = message
        self.context = context
    }

    public var description: String {
        if context.isEmpty {
            return message
        }

        let contextString = context
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")

        return "\(message) [\(contextString)]"
    }
}

extension ValidError {
    /// Creates a validation error with a field context.
    ///
    /// - Parameters:
    ///   - message: The error message.
    ///   - field: The field name that failed validation.
    public static func field(_ field: String, message: String) -> ValidError {
        ValidError(
            message: message,
            context: ["field": field]
        )
    }
}
