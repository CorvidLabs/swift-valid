import Testing
@testable import Valid

struct CompositionTests {
    // MARK: - And Validator Tests

    @Test func testAndValidatorBothValid() {
        let validator1 = LengthValidator(range: 3...10)
        let validator2 = NotEmptyValidator()
        let combined = validator1.and(validator2)

        #expect(combined.validate("hello").isValid)
    }

    @Test func testAndValidatorFirstInvalid() {
        let validator1 = LengthValidator(range: 3...10)
        let validator2 = NotEmptyValidator()
        let combined = validator1.and(validator2)

        let result = combined.validate("hi")
        #expect(result.isInvalid)
        #expect(result.errors.count >= 1)
    }

    @Test func testAndValidatorSecondInvalid() {
        let validator1 = LengthValidator(range: 0...10)
        let validator2 = NotEmptyValidator()
        let combined = validator1.and(validator2)

        let result = combined.validate("")
        #expect(result.isInvalid)
        #expect(result.errors.count >= 1)
    }

    @Test func testAndValidatorBothInvalid() {
        let validator1 = LengthValidator(range: 5...10)
        let validator2 = NotEmptyValidator()
        let combined = validator1.and(validator2)

        let result = combined.validate("")
        #expect(result.isInvalid)
        #expect(result.errors.count >= 2)
    }

    @Test func testAndValidatorChaining() {
        let validator = LengthValidator(range: 3...10)
            .and(NotEmptyValidator())
            .and(NotBlankValidator())

        #expect(validator.validate("hello").isValid)
        #expect(validator.validate("").isInvalid)
        #expect(validator.validate("   ").isInvalid)
        #expect(validator.validate("hi").isInvalid)
    }

    // MARK: - Or Validator Tests

    @Test func testOrValidatorBothValid() {
        let validator1 = LengthValidator(range: 3...5)
        let validator2 = LengthValidator(range: 8...10)
        let combined = validator1.or(validator2)

        #expect(combined.validate("abc").isValid)
        #expect(combined.validate("hello").isValid)
        #expect(combined.validate("abcdefgh").isValid)
    }

    @Test func testOrValidatorFirstValid() {
        let validator1 = LengthValidator(range: 3...5)
        let validator2 = LengthValidator(range: 8...10)
        let combined = validator1.or(validator2)

        #expect(combined.validate("test").isValid)
    }

    @Test func testOrValidatorSecondValid() {
        let validator1 = LengthValidator(range: 3...5)
        let validator2 = LengthValidator(range: 8...10)
        let combined = validator1.or(validator2)

        #expect(combined.validate("testing12").isValid)
    }

    @Test func testOrValidatorBothInvalid() {
        let validator1 = LengthValidator(range: 3...5)
        let validator2 = LengthValidator(range: 8...10)
        let combined = validator1.or(validator2)

        let result = combined.validate("ab")
        #expect(result.isInvalid)

        let result2 = combined.validate("toolongstring")
        #expect(result2.isInvalid)
    }

    @Test func testOrValidatorChaining() {
        let validator = LengthValidator(range: 1...3)
            .or(LengthValidator(range: 5...7))
            .or(LengthValidator(range: 9...11))

        #expect(validator.validate("ab").isValid)
        #expect(validator.validate("hello").isValid)
        #expect(validator.validate("abcdefghi").isValid)
        #expect(validator.validate("toolongstring").isInvalid)
    }

    // MARK: - Not Validator Tests

    @Test func testNotValidatorNegatesValid() {
        let baseValidator = LengthValidator(range: 3...10)
        let notValidator = baseValidator.not(message: "Must NOT be between 3 and 10")

        #expect(notValidator.validate("ab").isValid)
        #expect(notValidator.validate("verylongstring").isValid)
    }

    @Test func testNotValidatorNegatesInvalid() {
        let baseValidator = LengthValidator(range: 3...10)
        let notValidator = baseValidator.not(message: "Must NOT be between 3 and 10")

        let result = notValidator.validate("hello")
        #expect(result.isInvalid)
        #expect(result.errors.first?.message == "Must NOT be between 3 and 10")
    }

    @Test func testNotValidatorWithError() {
        let baseValidator = LengthValidator(range: 3...10)
        let error = ValidError(message: "Custom error", context: ["field": "test"])
        let notValidator = baseValidator.not(error: error)

        let result = notValidator.validate("hello")
        #expect(result.isInvalid)
        #expect(result.errors.first?.message == "Custom error")
        #expect(result.errors.first?.context["field"] == "test")
    }

    // MARK: - Complex Composition Tests

    @Test func testComplexAndOrComposition() {
        let shortValid = LengthValidator(range: 1...3)
        let longValid = LengthValidator(range: 8...10)
        let notBlank = NotBlankValidator()

        let validator = shortValid.or(longValid).and(notBlank)

        #expect(validator.validate("ab").isValid)
        #expect(validator.validate("abcdefgh").isValid)
        #expect(validator.validate("test").isInvalid)
        #expect(validator.validate("   ").isInvalid)
    }

    @Test func testAndOrNotComposition() {
        let length = LengthValidator(range: 5...10)
        let notEmpty = NotEmptyValidator()
        let containsTest = ContainsValidator(substring: "test")

        let validator = length.and(notEmpty).and(containsTest.not(message: "Must not contain 'test'"))

        #expect(validator.validate("hello").isValid)
        #expect(validator.validate("world!").isValid)
        #expect(validator.validate("testing").isInvalid)
    }

    // MARK: - AnyValidator Tests

    @Test func testAnyValidatorTypeErasure() {
        let lengthValidator = LengthValidator(range: 3...10)
        let anyValidator = lengthValidator.eraseToAnyValidator()

        #expect(anyValidator.validate("hello").isValid)
        #expect(anyValidator.validate("hi").isInvalid)
    }

    @Test func testAnyValidatorAlwaysValid() {
        let validator = AnyValidator<String>.valid

        #expect(validator.validate("").isValid)
        #expect(validator.validate("anything").isValid)
    }

    @Test func testAnyValidatorAlwaysInvalid() {
        let validator = AnyValidator<String>.invalid(message: "Always fails")

        let result = validator.validate("anything")
        #expect(result.isInvalid)
        #expect(result.errors.first?.message == "Always fails")
    }

    @Test func testAnyValidatorPredicate() {
        let validator = AnyValidator<String>.predicate(message: "Must contain 'swift'") { value in
            value.lowercased().contains("swift")
        }

        #expect(validator.validate("I love Swift").isValid)
        #expect(validator.validate("Hello World").isInvalid)
    }

    @Test func testAnyValidatorPredicateWithError() {
        let error = ValidError(message: "Custom error", context: ["type": "predicate"])
        let validator = AnyValidator<Int>.predicate(error: error) { $0 > 0 }

        let result = validator.validate(-5)
        #expect(result.isInvalid)
        #expect(result.errors.first?.message == "Custom error")
        #expect(result.errors.first?.context["type"] == "predicate")
    }

    // MARK: - ValidationResult Tests

    @Test func testValidationResultAnd() {
        let valid = ValidationResult.valid
        let invalid = ValidationResult.invalid([ValidError(message: "error")])

        #expect(valid.and(valid).isValid)
        #expect(valid.and(invalid).isInvalid)
        #expect(invalid.and(valid).isInvalid)
        #expect(invalid.and(invalid).isInvalid)
    }

    @Test func testValidationResultOr() {
        let valid = ValidationResult.valid
        let invalid = ValidationResult.invalid([ValidError(message: "error")])

        #expect(valid.or(valid).isValid)
        #expect(valid.or(invalid).isValid)
        #expect(invalid.or(valid).isValid)
        #expect(invalid.or(invalid).isInvalid)
    }

    @Test func testValidationResultFrom() {
        let validResult = ValidationResult.from(true, message: "error")
        let invalidResult = ValidationResult.from(false, message: "error")

        #expect(validResult.isValid)
        #expect(invalidResult.isInvalid)
    }

    @Test func testValidationResultErrors() {
        let error1 = ValidError(message: "error1")
        let error2 = ValidError(message: "error2")
        let invalid = ValidationResult.invalid([error1, error2])

        #expect(invalid.errors.count == 2)
        #expect(invalid.errors[0].message == "error1")
        #expect(invalid.errors[1].message == "error2")

        let valid = ValidationResult.valid
        #expect(valid.errors.isEmpty)
    }
}
