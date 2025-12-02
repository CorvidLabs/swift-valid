import Testing
@testable import Valid

struct NumericValidationTests {
    // MARK: - Range Validator Tests

    @Test func testRangeValidatorInRange() {
        let validator = RangeValidator(range: 1...10)

        #expect(validator.validate(1).isValid)
        #expect(validator.validate(5).isValid)
        #expect(validator.validate(10).isValid)
    }

    @Test func testRangeValidatorOutOfRange() {
        let validator = RangeValidator(range: 1...10)

        #expect(validator.validate(0).isInvalid)
        #expect(validator.validate(11).isInvalid)
        #expect(validator.validate(-5).isInvalid)
    }

    @Test func testRangeValidatorDouble() {
        let validator = RangeValidator(range: 0.0...1.0)

        #expect(validator.validate(0.5).isValid)
        #expect(validator.validate(0.0).isValid)
        #expect(validator.validate(1.0).isValid)
        #expect(validator.validate(1.1).isInvalid)
    }

    // MARK: - Minimum Validator Tests

    @Test func testMinimumValidatorInclusive() {
        let validator = MinimumValidator(minimum: 5, inclusive: true)

        #expect(validator.validate(5).isValid)
        #expect(validator.validate(6).isValid)
        #expect(validator.validate(4).isInvalid)
    }

    @Test func testMinimumValidatorExclusive() {
        let validator = MinimumValidator(minimum: 5, inclusive: false)

        #expect(validator.validate(6).isValid)
        #expect(validator.validate(5).isInvalid)
        #expect(validator.validate(4).isInvalid)
    }

    // MARK: - Maximum Validator Tests

    @Test func testMaximumValidatorInclusive() {
        let validator = MaximumValidator(maximum: 10, inclusive: true)

        #expect(validator.validate(10).isValid)
        #expect(validator.validate(9).isValid)
        #expect(validator.validate(11).isInvalid)
    }

    @Test func testMaximumValidatorExclusive() {
        let validator = MaximumValidator(maximum: 10, inclusive: false)

        #expect(validator.validate(9).isValid)
        #expect(validator.validate(10).isInvalid)
        #expect(validator.validate(11).isInvalid)
    }

    // MARK: - Positive Validator Tests

    @Test func testPositiveValidatorStrict() {
        let validator = PositiveValidator<Int>(strict: true)

        #expect(validator.validate(1).isValid)
        #expect(validator.validate(100).isValid)
        #expect(validator.validate(0).isInvalid)
        #expect(validator.validate(-1).isInvalid)
    }

    @Test func testPositiveValidatorNonStrict() {
        let validator = PositiveValidator<Int>(strict: false)

        #expect(validator.validate(1).isValid)
        #expect(validator.validate(0).isValid)
        #expect(validator.validate(-1).isInvalid)
    }

    @Test func testPositiveValidatorDouble() {
        let validator = PositiveValidator<Double>(strict: true)

        #expect(validator.validate(0.1).isValid)
        #expect(validator.validate(0.0).isInvalid)
        #expect(validator.validate(-0.1).isInvalid)
    }

    // MARK: - Negative Validator Tests

    @Test func testNegativeValidatorStrict() {
        let validator = NegativeValidator<Int>(strict: true)

        #expect(validator.validate(-1).isValid)
        #expect(validator.validate(-100).isValid)
        #expect(validator.validate(0).isInvalid)
        #expect(validator.validate(1).isInvalid)
    }

    @Test func testNegativeValidatorNonStrict() {
        let validator = NegativeValidator<Int>(strict: false)

        #expect(validator.validate(-1).isValid)
        #expect(validator.validate(0).isValid)
        #expect(validator.validate(1).isInvalid)
    }

    // MARK: - Even Validator Tests

    @Test func testEvenValidator() {
        let validator = EvenValidator<Int>()

        #expect(validator.validate(0).isValid)
        #expect(validator.validate(2).isValid)
        #expect(validator.validate(-4).isValid)
        #expect(validator.validate(1).isInvalid)
        #expect(validator.validate(-3).isInvalid)
    }

    // MARK: - Odd Validator Tests

    @Test func testOddValidator() {
        let validator = OddValidator<Int>()

        #expect(validator.validate(1).isValid)
        #expect(validator.validate(3).isValid)
        #expect(validator.validate(-5).isValid)
        #expect(validator.validate(0).isInvalid)
        #expect(validator.validate(2).isInvalid)
    }

    // MARK: - Multiple Of Validator Tests

    @Test func testMultipleOfValidator() {
        let validator = MultipleOfValidator(divisor: 5)

        #expect(validator.validate(0).isValid)
        #expect(validator.validate(5).isValid)
        #expect(validator.validate(10).isValid)
        #expect(validator.validate(-15).isValid)
        #expect(validator.validate(3).isInvalid)
        #expect(validator.validate(7).isInvalid)
    }

    // MARK: - Convenience Extension Tests

    @Test func testNumericValidatorConvenience() {
        let rangeValidator: RangeValidator<Int> = .range(1...10)
        let minValidator: MinimumValidator<Int> = .min(5)
        let maxValidator: MaximumValidator<Int> = .max(100)
        let positiveValidator: PositiveValidator<Int> = .positive()

        #expect(rangeValidator.validate(5).isValid)
        #expect(minValidator.validate(10).isValid)
        #expect(maxValidator.validate(50).isValid)
        #expect(positiveValidator.validate(1).isValid)
    }

    @Test func testIntegerValidatorConvenience() {
        let evenValidator: EvenValidator<Int> = .even
        let oddValidator: OddValidator<Int> = .odd
        let multipleValidator: MultipleOfValidator<Int> = .multipleOf(3)

        #expect(evenValidator.validate(4).isValid)
        #expect(oddValidator.validate(5).isValid)
        #expect(multipleValidator.validate(9).isValid)
    }
}
