import Foundation

// MARK: - Length Validator

/// Validates that a string's length falls within a specified range.
public struct LengthValidator: Validator, Sendable {
    public typealias Value = String

    private let range: ClosedRange<Int>

    /**
     Creates a length validator.

     - Parameter range: The acceptable length range.
     */
    public init(range: ClosedRange<Int>) {
        self.range = range
    }

    public func validate(_ value: String) -> ValidationResult {
        let length = value.count
        guard range.contains(length) else {
            return .invalid([
                ValidError(
                    message: "Length must be between \(range.lowerBound) and \(range.upperBound), got \(length)"
                )
            ])
        }
        return .valid
    }
}

extension LengthValidator {
    /**
     Creates a validator for exact length.

     - Parameter length: The required length.
     */
    public static func exactly(_ length: Int) -> LengthValidator {
        LengthValidator(range: length...length)
    }

    /**
     Creates a validator for minimum length.

     - Parameter minimum: The minimum length.
     */
    public static func minimum(_ minimum: Int) -> LengthValidator {
        LengthValidator(range: minimum...Int.max)
    }

    /**
     Creates a validator for maximum length.

     - Parameter maximum: The maximum length.
     */
    public static func maximum(_ maximum: Int) -> LengthValidator {
        LengthValidator(range: 0...maximum)
    }
}

// MARK: - Not Empty Validator

/// Validates that a string is not empty.
public struct NotEmptyValidator: Validator, Sendable {
    public typealias Value = String

    public init() {}

    public func validate(_ value: String) -> ValidationResult {
        .from(!value.isEmpty, message: "String must not be empty")
    }
}

// MARK: - Not Blank Validator

/// Validates that a string is not blank (contains non-whitespace characters).
public struct NotBlankValidator: Validator, Sendable {
    public typealias Value = String

    public init() {}

    public func validate(_ value: String) -> ValidationResult {
        let isBlank = value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return .from(!isBlank, message: "String must not be blank")
    }
}

// MARK: - Email Validator

/// Validates that a string is a valid email address.
public struct EmailValidator: Validator, Sendable {
    public typealias Value = String

    private static let emailPattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

    public init() {}

    public func validate(_ value: String) -> ValidationResult {
        guard let regex = try? NSRegularExpression(pattern: Self.emailPattern) else {
            return .invalid([ValidError(message: "Invalid email pattern")])
        }

        let range = NSRange(value.startIndex..., in: value)
        let matches = regex.firstMatch(in: value, range: range) != nil

        return .from(matches, message: "Invalid email format")
    }
}

// MARK: - Pattern Validator

/// Validates that a string matches a regular expression pattern.
public struct PatternValidator: Validator, Sendable {
    public typealias Value = String

    private let pattern: String
    private let message: String

    /**
     Creates a pattern validator.

     - Parameters:
       - pattern: The regular expression pattern.
       - message: The error message when validation fails.
     */
    public init(pattern: String, message: String = "String does not match required pattern") {
        self.pattern = pattern
        self.message = message
    }

    public func validate(_ value: String) -> ValidationResult {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return .invalid([ValidError(message: "Invalid regex pattern")])
        }

        let range = NSRange(value.startIndex..., in: value)
        let matches = regex.firstMatch(in: value, range: range) != nil

        return .from(matches, message: message)
    }
}

// MARK: - Contains Validator

/// Validates that a string contains a specific substring.
public struct ContainsValidator: Validator, Sendable {
    public typealias Value = String

    private let substring: String
    private let caseSensitive: Bool

    /**
     Creates a contains validator.

     - Parameters:
       - substring: The substring to search for.
       - caseSensitive: Whether the search is case-sensitive.
     */
    public init(substring: String, caseSensitive: Bool = true) {
        self.substring = substring
        self.caseSensitive = caseSensitive
    }

    public func validate(_ value: String) -> ValidationResult {
        let contains: Bool
        if caseSensitive {
            contains = value.contains(substring)
        } else {
            contains = value.lowercased().contains(substring.lowercased())
        }

        return .from(
            contains,
            message: "String must contain '\(substring)'"
        )
    }
}

// MARK: - Prefix Validator

/// Validates that a string starts with a specific prefix.
public struct PrefixValidator: Validator, Sendable {
    public typealias Value = String

    private let prefix: String

    /**
     Creates a prefix validator.

     - Parameter prefix: The required prefix.
     */
    public init(prefix: String) {
        self.prefix = prefix
    }

    public func validate(_ value: String) -> ValidationResult {
        .from(
            value.hasPrefix(prefix),
            message: "String must start with '\(prefix)'"
        )
    }
}

// MARK: - Suffix Validator

/// Validates that a string ends with a specific suffix.
public struct SuffixValidator: Validator, Sendable {
    public typealias Value = String

    private let suffix: String

    /**
     Creates a suffix validator.

     - Parameter suffix: The required suffix.
     */
    public init(suffix: String) {
        self.suffix = suffix
    }

    public func validate(_ value: String) -> ValidationResult {
        .from(
            value.hasSuffix(suffix),
            message: "String must end with '\(suffix)'"
        )
    }
}

// MARK: - Convenience Extensions

extension Validator where Value == String {
    /// Validates string length.
    public static func length(_ range: ClosedRange<Int>) -> LengthValidator {
        LengthValidator(range: range)
    }

    /// Validates exact string length.
    public static func length(exactly: Int) -> LengthValidator {
        LengthValidator.exactly(exactly)
    }

    /// Validates minimum string length.
    public static func length(minimum: Int) -> LengthValidator {
        LengthValidator.minimum(minimum)
    }

    /// Validates maximum string length.
    public static func length(maximum: Int) -> LengthValidator {
        LengthValidator.maximum(maximum)
    }

    /// Validates string is not empty.
    public static var notEmpty: NotEmptyValidator {
        NotEmptyValidator()
    }

    /// Validates string is not blank.
    public static var notBlank: NotBlankValidator {
        NotBlankValidator()
    }

    /// Validates email format.
    public static var email: EmailValidator {
        EmailValidator()
    }

    /// Validates string matches a pattern.
    public static func pattern(_ pattern: String, message: String = "String does not match required pattern") -> PatternValidator {
        PatternValidator(pattern: pattern, message: message)
    }

    /// Validates string contains a substring.
    public static func contains(_ substring: String, caseSensitive: Bool = true) -> ContainsValidator {
        ContainsValidator(substring: substring, caseSensitive: caseSensitive)
    }

    /// Validates string starts with a prefix.
    public static func hasPrefix(_ prefix: String) -> PrefixValidator {
        PrefixValidator(prefix: prefix)
    }

    /// Validates string ends with a suffix.
    public static func hasSuffix(_ suffix: String) -> SuffixValidator {
        SuffixValidator(suffix: suffix)
    }
}
