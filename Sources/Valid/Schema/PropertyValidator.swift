/// A validator for a specific property of an object.
///
/// Use this to validate individual properties of a struct or class with
/// descriptive field names in error messages.
public struct PropertyValidator<Root, Value>: Validator
where Root: Sendable, Value: Sendable {
    private let keyPath: KeyPath<Root, Value>
    private let fieldName: String
    private let valueValidator: AnyValidator<Value>

    /**
     Creates a property validator.

     - Parameters:
       - keyPath: The key path to the property.
       - fieldName: The name of the field for error messages.
       - validator: The validator to apply to the property value.
     */
    public init<V: Validator>(
        _ keyPath: KeyPath<Root, Value>,
        fieldName: String,
        validator: V
    ) where V.Value == Value {
        self.keyPath = keyPath
        self.fieldName = fieldName
        self.valueValidator = validator.eraseToAnyValidator()
    }

    public func validate(_ value: Root) -> ValidationResult {
        let propertyValue = value[keyPath: keyPath]
        let result = valueValidator.validate(propertyValue)

        if case .invalid(let errors) = result {
            let fieldErrors = errors.map { error in
                ValidError(
                    message: error.message,
                    context: error.context.merging(["field": fieldName]) { _, new in new }
                )
            }
            return .invalid(fieldErrors)
        }

        return result
    }
}

extension PropertyValidator: @unchecked Sendable where Root: Sendable, Value: Sendable {}

extension PropertyValidator {
    /**
     Creates a property validator using a custom validation closure.

     - Parameters:
       - keyPath: The key path to the property.
       - fieldName: The name of the field for error messages.
       - validate: The validation closure.
     */
    public init(
        _ keyPath: KeyPath<Root, Value>,
        fieldName: String,
        validate: @escaping @Sendable (Value) -> ValidationResult
    ) {
        self.init(
            keyPath,
            fieldName: fieldName,
            validator: AnyValidator(validate: validate)
        )
    }
}

// MARK: - Schema Builder

/**
 A result builder for creating validation schemas.

 `SchemaBuilder` allows you to compose multiple property validators
 using a declarative syntax with the `@SchemaBuilder` attribute.

 ## Example
 ```swift
 let validator = Schema<User>.build {
     Schema.property(\.username, fieldName: "username", validator: LengthValidator(range: 3...20))
     Schema.property(\.email, fieldName: "email", validator: EmailValidator())
     Schema.property(\.age, fieldName: "age", validator: RangeValidator(range: 18...120))
 }
 ```
 */
@resultBuilder
public struct SchemaBuilder<Root> where Root: Sendable {
    public static func buildBlock<V: Validator>(_ validator: V) -> V where V.Value == Root {
        validator
    }

    public static func buildBlock<V1: Validator, V2: Validator>(
        _ v1: V1,
        _ v2: V2
    ) -> AndValidator<V1, V2>
    where V1.Value == Root, V2.Value == Root {
        v1.and(v2)
    }

    public static func buildBlock<V1: Validator, V2: Validator, V3: Validator>(
        _ v1: V1,
        _ v2: V2,
        _ v3: V3
    ) -> AndValidator<AndValidator<V1, V2>, V3>
    where V1.Value == Root, V2.Value == Root, V3.Value == Root {
        v1.and(v2).and(v3)
    }

    public static func buildBlock<V1: Validator, V2: Validator, V3: Validator, V4: Validator>(
        _ v1: V1,
        _ v2: V2,
        _ v3: V3,
        _ v4: V4
    ) -> AndValidator<AndValidator<AndValidator<V1, V2>, V3>, V4>
    where V1.Value == Root, V2.Value == Root, V3.Value == Root, V4.Value == Root {
        v1.and(v2).and(v3).and(v4)
    }

    public static func buildBlock<V1: Validator, V2: Validator, V3: Validator, V4: Validator, V5: Validator>(
        _ v1: V1,
        _ v2: V2,
        _ v3: V3,
        _ v4: V4,
        _ v5: V5
    ) -> AndValidator<AndValidator<AndValidator<AndValidator<V1, V2>, V3>, V4>, V5>
    where V1.Value == Root, V2.Value == Root, V3.Value == Root, V4.Value == Root, V5.Value == Root {
        v1.and(v2).and(v3).and(v4).and(v5)
    }

    public static func buildBlock<V1: Validator, V2: Validator, V3: Validator, V4: Validator, V5: Validator, V6: Validator>(
        _ v1: V1,
        _ v2: V2,
        _ v3: V3,
        _ v4: V4,
        _ v5: V5,
        _ v6: V6
    ) -> AndValidator<AndValidator<AndValidator<AndValidator<AndValidator<V1, V2>, V3>, V4>, V5>, V6>
    where V1.Value == Root, V2.Value == Root, V3.Value == Root, V4.Value == Root, V5.Value == Root, V6.Value == Root {
        v1.and(v2).and(v3).and(v4).and(v5).and(v6)
    }
}

// MARK: - Schema Helper

/// Helper for building validation schemas.
///
/// `Schema` provides a namespace for schema-building functionality,
/// including the `build` method for creating validators using result builders
/// and the `property` methods for creating property validators.
///
/// ## Topics
///
/// ### Building Schemas
/// - ``build(_:)``
///
/// ### Creating Property Validators
/// - ``property(_:fieldName:validator:)``
/// - ``property(_:fieldName:validate:)``
public enum Schema<Root> where Root: Sendable {
    /**
     Creates a validator from a result builder.

     - Parameter builder: The schema builder.
     - Returns: A validator for the schema.
     */
    public static func build<V: Validator>(
        @SchemaBuilder<Root> _ builder: () -> V
    ) -> V where V.Value == Root {
        builder()
    }

    /**
     Creates a property validator.

     - Parameters:
       - keyPath: The key path to the property.
       - fieldName: The name of the field for error messages.
       - validator: The validator to apply to the property value.
     - Returns: A property validator.
     */
    public static func property<Value, V: Validator>(
        _ keyPath: KeyPath<Root, Value>,
        fieldName: String,
        validator: V
    ) -> PropertyValidator<Root, Value> where V.Value == Value, Value: Sendable {
        PropertyValidator(keyPath, fieldName: fieldName, validator: validator)
    }

    /**
     Creates a property validator using a validation closure.

     - Parameters:
       - keyPath: The key path to the property.
       - fieldName: The name of the field for error messages.
       - validate: The validation closure.
     - Returns: A property validator.
     */
    public static func property<Value>(
        _ keyPath: KeyPath<Root, Value>,
        fieldName: String,
        validate: @escaping @Sendable (Value) -> ValidationResult
    ) -> PropertyValidator<Root, Value> where Value: Sendable {
        PropertyValidator(keyPath, fieldName: fieldName, validate: validate)
    }
}
