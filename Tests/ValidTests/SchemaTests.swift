import Testing
@testable import Valid

struct SchemaTests {
    // MARK: - Test Models

    struct User: Sendable {
        let username: String
        let email: String
        let age: Int
    }

    struct Product: Sendable {
        let name: String
        let price: Double
        let tags: [String]
    }

    struct ValidatableUser: Validatable, Sendable {
        let username: String
        let email: String
        let age: Int

        func validate() -> ValidationResult {
            Schema<ValidatableUser>.build {
                Schema.property(\ValidatableUser.username, fieldName: "username", validator: LengthValidator(range: 3...20))
                Schema.property(\ValidatableUser.email, fieldName: "email", validator: EmailValidator())
                Schema.property(\ValidatableUser.age, fieldName: "age", validator: RangeValidator(range: 18...120))
            }
            .validate(self)
        }
    }

    // MARK: - Property Validator Tests

    @Test func testPropertyValidatorValid() {
        let validator = PropertyValidator(
            \User.username,
            fieldName: "username",
            validator: LengthValidator(range: 3...20)
        )

        let user = User(username: "johndoe", email: "john@example.com", age: 25)
        #expect(validator.validate(user).isValid)
    }

    @Test func testPropertyValidatorInvalid() {
        let validator = PropertyValidator(
            \User.username,
            fieldName: "username",
            validator: LengthValidator(range: 3...20)
        )

        let user = User(username: "ab", email: "john@example.com", age: 25)
        let result = validator.validate(user)

        #expect(result.isInvalid)
        #expect(result.errors.first?.context["field"] == "username")
    }

    @Test func testPropertyValidatorWithClosure() {
        let validator = PropertyValidator(
            \User.age,
            fieldName: "age"
        ) { age in
            .from(age >= 18, message: "Must be 18 or older")
        }

        let validUser = User(username: "johndoe", email: "john@example.com", age: 25)
        let invalidUser = User(username: "johndoe", email: "john@example.com", age: 15)

        #expect(validator.validate(validUser).isValid)
        #expect(validator.validate(invalidUser).isInvalid)
    }

    @Test func testPropertyValidatorMultipleErrors() {
        let validator = PropertyValidator(
            \User.username,
            fieldName: "username",
            validator: LengthValidator(range: 3...20).and(NotEmptyValidator())
        )

        let user = User(username: "", email: "john@example.com", age: 25)
        let result = validator.validate(user)

        #expect(result.isInvalid)
        #expect(result.errors.count >= 2)
    }

    // MARK: - Schema Builder Tests

    @Test func testSchemaBuilderSingleValidator() {
        let validator = Schema<User>.build {
            Schema.property(\User.username, fieldName: "username", validator: LengthValidator(range: 3...20))
        }

        let validUser = User(username: "johndoe", email: "john@example.com", age: 25)
        let invalidUser = User(username: "ab", email: "john@example.com", age: 25)

        #expect(validator.validate(validUser).isValid)
        #expect(validator.validate(invalidUser).isInvalid)
    }

    @Test func testSchemaBuilderMultipleValidators() {
        let validator = Schema<User>.build {
            Schema.property(\User.username, fieldName: "username", validator: LengthValidator(range: 3...20))
            Schema.property(\User.email, fieldName: "email", validator: EmailValidator())
            Schema.property(\User.age, fieldName: "age", validator: RangeValidator(range: 18...120))
        }

        let validUser = User(username: "johndoe", email: "john@example.com", age: 25)
        #expect(validator.validate(validUser).isValid)
    }

    @Test func testSchemaBuilderInvalidUsername() {
        let validator = Schema<User>.build {
            Schema.property(\User.username, fieldName: "username", validator: LengthValidator(range: 3...20))
            Schema.property(\User.email, fieldName: "email", validator: EmailValidator())
            Schema.property(\User.age, fieldName: "age", validator: RangeValidator(range: 18...120))
        }

        let user = User(username: "ab", email: "john@example.com", age: 25)
        let result = validator.validate(user)

        #expect(result.isInvalid)
        #expect(result.errors.contains { $0.context["field"] == "username" })
    }

    @Test func testSchemaBuilderInvalidEmail() {
        let validator = Schema<User>.build {
            Schema.property(\User.username, fieldName: "username", validator: LengthValidator(range: 3...20))
            Schema.property(\User.email, fieldName: "email", validator: EmailValidator())
            Schema.property(\User.age, fieldName: "age", validator: RangeValidator(range: 18...120))
        }

        let user = User(username: "johndoe", email: "invalid-email", age: 25)
        let result = validator.validate(user)

        #expect(result.isInvalid)
        #expect(result.errors.contains { $0.context["field"] == "email" })
    }

    @Test func testSchemaBuilderInvalidAge() {
        let validator = Schema<User>.build {
            Schema.property(\User.username, fieldName: "username", validator: LengthValidator(range: 3...20))
            Schema.property(\User.email, fieldName: "email", validator: EmailValidator())
            Schema.property(\User.age, fieldName: "age", validator: RangeValidator(range: 18...120))
        }

        let user = User(username: "johndoe", email: "john@example.com", age: 15)
        let result = validator.validate(user)

        #expect(result.isInvalid)
        #expect(result.errors.contains { $0.context["field"] == "age" })
    }

    @Test func testSchemaBuilderMultipleInvalidFields() {
        let validator = Schema<User>.build {
            Schema.property(\User.username, fieldName: "username", validator: LengthValidator(range: 3...20))
            Schema.property(\User.email, fieldName: "email", validator: EmailValidator())
            Schema.property(\User.age, fieldName: "age", validator: RangeValidator(range: 18...120))
        }

        let user = User(username: "ab", email: "invalid", age: 15)
        let result = validator.validate(user)

        #expect(result.isInvalid)
        #expect(result.errors.count >= 3)
    }

    @Test func testSchemaBuilderWithCollections() {
        let validator = Schema<Product>.build {
            Schema.property(\Product.name, fieldName: "name", validator: NotEmptyValidator())
            Schema.property(\Product.price, fieldName: "price", validator: PositiveValidator<Double>())
            Schema.property(\Product.tags, fieldName: "tags", validator: CountValidator<[String]>.minimum(1))
        }

        let validProduct = Product(name: "Widget", price: 19.99, tags: ["new", "sale"])
        let invalidProduct = Product(name: "", price: -5.0, tags: [])

        #expect(validator.validate(validProduct).isValid)
        #expect(validator.validate(invalidProduct).isInvalid)
    }

    // MARK: - Validatable Protocol Tests

    @Test func testValidatableProtocolValid() {
        let user = ValidatableUser(username: "johndoe", email: "john@example.com", age: 25)

        #expect(user.isValid)
        #expect(user.validationErrors.isEmpty)
    }

    @Test func testValidatableProtocolInvalid() {
        let user = ValidatableUser(username: "ab", email: "invalid", age: 15)

        #expect(!user.isValid)
        #expect(!user.validationErrors.isEmpty)
        #expect(user.validationErrors.count >= 3)
    }

    @Test func testValidatableValidateMethod() {
        let validUser = ValidatableUser(username: "johndoe", email: "john@example.com", age: 25)
        let invalidUser = ValidatableUser(username: "ab", email: "invalid", age: 15)

        #expect(validUser.validate().isValid)
        #expect(invalidUser.validate().isInvalid)
    }

    @Test func testValidatableValidateOrThrow() throws {
        let validUser = ValidatableUser(username: "johndoe", email: "john@example.com", age: 25)
        let invalidUser = ValidatableUser(username: "ab", email: "invalid", age: 15)

        try validUser.validateOrThrow()

        var didThrow = false
        do {
            try invalidUser.validateOrThrow()
        } catch {
            didThrow = true
        }
        #expect(didThrow)
    }

    @Test func testValidatableStaticValidator() {
        let validator = ValidatableUser.validator()

        let validUser = ValidatableUser(username: "johndoe", email: "john@example.com", age: 25)
        let invalidUser = ValidatableUser(username: "ab", email: "invalid", age: 15)

        #expect(validator.validate(validUser).isValid)
        #expect(validator.validate(invalidUser).isInvalid)
    }

    // MARK: - Validator Extension Tests

    @Test func testValidatorIsValid() {
        let validator = LengthValidator(range: 3...10)

        #expect(validator.isValid("hello"))
        #expect(!validator.isValid("hi"))
    }

    @Test func testValidatorValidateOrThrow() throws {
        let validator = LengthValidator(range: 3...10)

        try validator.validateOrThrow("hello")

        var didThrow = false
        do {
            try validator.validateOrThrow("hi")
        } catch {
            didThrow = true
        }
        #expect(didThrow)
    }

    // MARK: - Complex Schema Tests

    @Test func testComplexSchemaWithNestedValidation() {
        struct Address: Sendable {
            let street: String
            let city: String
            let zipCode: String
        }

        struct Person: Sendable {
            let name: String
            let age: Int
            let email: String
        }

        let personValidator = Schema<Person>.build {
            Schema.property(\Person.name, fieldName: "name", validator: NotBlankValidator().and(LengthValidator.minimum(2)))
            Schema.property(\Person.age, fieldName: "age", validator: RangeValidator(range: 0...150))
            Schema.property(\Person.email, fieldName: "email", validator: EmailValidator())
        }

        let validPerson = Person(name: "John Doe", age: 30, email: "john@example.com")
        let invalidPerson = Person(name: " ", age: 200, email: "not-an-email")

        #expect(personValidator.validate(validPerson).isValid)

        let result = personValidator.validate(invalidPerson)
        #expect(result.isInvalid)
        #expect(result.errors.count >= 3)
    }
}
