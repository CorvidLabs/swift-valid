import Testing
@testable import Valid

struct StringValidationTests {
    // MARK: - Length Validator Tests

    @Test func testLengthValidatorInRange() {
        let validator = LengthValidator(range: 3...10)

        #expect(validator.validate("hello").isValid)
        #expect(validator.validate("abc").isValid)
        #expect(validator.validate("1234567890").isValid)
    }

    @Test func testLengthValidatorTooShort() {
        let validator = LengthValidator(range: 3...10)
        let result = validator.validate("ab")

        #expect(result.isInvalid)
        #expect(result.errors.count == 1)
    }

    @Test func testLengthValidatorTooLong() {
        let validator = LengthValidator(range: 3...10)
        let result = validator.validate("12345678901")

        #expect(result.isInvalid)
        #expect(result.errors.count == 1)
    }

    @Test func testLengthValidatorExactly() {
        let validator = LengthValidator.exactly(5)

        #expect(validator.validate("hello").isValid)
        #expect(validator.validate("hi").isInvalid)
        #expect(validator.validate("toolong").isInvalid)
    }

    @Test func testLengthValidatorMinimum() {
        let validator = LengthValidator.minimum(3)

        #expect(validator.validate("abc").isValid)
        #expect(validator.validate("abcdef").isValid)
        #expect(validator.validate("ab").isInvalid)
    }

    @Test func testLengthValidatorMaximum() {
        let validator = LengthValidator.maximum(5)

        #expect(validator.validate("").isValid)
        #expect(validator.validate("hello").isValid)
        #expect(validator.validate("toolong").isInvalid)
    }

    // MARK: - Not Empty Validator Tests

    @Test func testNotEmptyValidatorWithContent() {
        let validator = NotEmptyValidator()
        #expect(validator.validate("hello").isValid)
    }

    @Test func testNotEmptyValidatorEmpty() {
        let validator = NotEmptyValidator()
        let result = validator.validate("")

        #expect(result.isInvalid)
        #expect(result.errors.count == 1)
    }

    // MARK: - Not Blank Validator Tests

    @Test func testNotBlankValidatorWithContent() {
        let validator = NotBlankValidator()
        #expect(validator.validate("hello").isValid)
    }

    @Test func testNotBlankValidatorEmpty() {
        let validator = NotBlankValidator()
        #expect(validator.validate("").isInvalid)
    }

    @Test func testNotBlankValidatorWhitespace() {
        let validator = NotBlankValidator()
        #expect(validator.validate("   ").isInvalid)
        #expect(validator.validate("\n\t  ").isInvalid)
    }

    @Test func testNotBlankValidatorMixed() {
        let validator = NotBlankValidator()
        #expect(validator.validate("  hello  ").isValid)
    }

    // MARK: - Email Validator Tests

    @Test func testEmailValidatorValid() {
        let validator = EmailValidator()

        #expect(validator.validate("test@example.com").isValid)
        #expect(validator.validate("user.name@example.co.uk").isValid)
        #expect(validator.validate("user+tag@example.com").isValid)
        #expect(validator.validate("user123@test-domain.com").isValid)
    }

    @Test func testEmailValidatorInvalid() {
        let validator = EmailValidator()

        #expect(validator.validate("invalid").isInvalid)
        #expect(validator.validate("@example.com").isInvalid)
        #expect(validator.validate("user@").isInvalid)
        #expect(validator.validate("user@domain").isInvalid)
        #expect(validator.validate("user @example.com").isInvalid)
    }

    // MARK: - Pattern Validator Tests

    @Test func testPatternValidatorMatches() {
        let validator = PatternValidator(pattern: "^[0-9]{3}-[0-9]{4}$")

        #expect(validator.validate("123-4567").isValid)
    }

    @Test func testPatternValidatorNoMatch() {
        let validator = PatternValidator(pattern: "^[0-9]{3}-[0-9]{4}$")

        #expect(validator.validate("12-34567").isInvalid)
        #expect(validator.validate("abc-defg").isInvalid)
    }

    @Test func testPatternValidatorCustomMessage() {
        let validator = PatternValidator(
            pattern: "^[A-Z][0-9]{3}$",
            message: "Must be one uppercase letter followed by three digits"
        )

        let result = validator.validate("invalid")
        #expect(result.isInvalid)
        #expect(result.errors.first?.message == "Must be one uppercase letter followed by three digits")
    }

    // MARK: - Contains Validator Tests

    @Test func testContainsValidatorCaseSensitive() {
        let validator = ContainsValidator(substring: "test")

        #expect(validator.validate("this is a test").isValid)
        #expect(validator.validate("testing").isValid)
        #expect(validator.validate("This is a Test").isInvalid)
    }

    @Test func testContainsValidatorCaseInsensitive() {
        let validator = ContainsValidator(substring: "test", caseSensitive: false)

        #expect(validator.validate("this is a TEST").isValid)
        #expect(validator.validate("Testing").isValid)
        #expect(validator.validate("no match").isInvalid)
    }

    // MARK: - Prefix Validator Tests

    @Test func testPrefixValidatorMatches() {
        let validator = PrefixValidator(prefix: "hello")

        #expect(validator.validate("hello world").isValid)
        #expect(validator.validate("hello").isValid)
    }

    @Test func testPrefixValidatorNoMatch() {
        let validator = PrefixValidator(prefix: "hello")

        #expect(validator.validate("goodbye world").isInvalid)
        #expect(validator.validate("ello").isInvalid)
    }

    // MARK: - Suffix Validator Tests

    @Test func testSuffixValidatorMatches() {
        let validator = SuffixValidator(suffix: ".txt")

        #expect(validator.validate("file.txt").isValid)
        #expect(validator.validate(".txt").isValid)
    }

    @Test func testSuffixValidatorNoMatch() {
        let validator = SuffixValidator(suffix: ".txt")

        #expect(validator.validate("file.pdf").isInvalid)
        #expect(validator.validate("txt").isInvalid)
    }

    // MARK: - Convenience Extension Tests

    @Test func testStringValidatorConvenience() {
        let lengthValidator: LengthValidator = .length(3...10)
        let notEmptyValidator: NotEmptyValidator = .notEmpty
        let notBlankValidator: NotBlankValidator = .notBlank
        let emailValidator: EmailValidator = .email

        #expect(lengthValidator.validate("hello").isValid)
        #expect(notEmptyValidator.validate("x").isValid)
        #expect(notBlankValidator.validate("x").isValid)
        #expect(emailValidator.validate("test@example.com").isValid)
    }
}
