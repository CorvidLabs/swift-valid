import Testing
@testable import Valid

struct CollectionValidationTests {
    // MARK: - Count Validator Tests

    @Test func testCountValidatorInRange() {
        let validator = CountValidator<[Int]>(range: 2...5)

        #expect(validator.validate([1, 2]).isValid)
        #expect(validator.validate([1, 2, 3]).isValid)
        #expect(validator.validate([1, 2, 3, 4, 5]).isValid)
    }

    @Test func testCountValidatorOutOfRange() {
        let validator = CountValidator<[Int]>(range: 2...5)

        #expect(validator.validate([1]).isInvalid)
        #expect(validator.validate([]).isInvalid)
        #expect(validator.validate([1, 2, 3, 4, 5, 6]).isInvalid)
    }

    @Test func testCountValidatorExactly() {
        let validator = CountValidator<[String]>.exactly(3)

        #expect(validator.validate(["a", "b", "c"]).isValid)
        #expect(validator.validate(["a", "b"]).isInvalid)
        #expect(validator.validate(["a", "b", "c", "d"]).isInvalid)
    }

    @Test func testCountValidatorMinimum() {
        let validator = CountValidator<[Int]>.minimum(2)

        #expect(validator.validate([1, 2]).isValid)
        #expect(validator.validate([1, 2, 3]).isValid)
        #expect(validator.validate([1]).isInvalid)
    }

    @Test func testCountValidatorMaximum() {
        let validator = CountValidator<[Int]>.maximum(3)

        #expect(validator.validate([]).isValid)
        #expect(validator.validate([1, 2, 3]).isValid)
        #expect(validator.validate([1, 2, 3, 4]).isInvalid)
    }

    // MARK: - Collection Not Empty Validator Tests

    @Test func testCollectionNotEmptyValidator() {
        let validator = CollectionNotEmptyValidator<[Int]>()

        #expect(validator.validate([1]).isValid)
        #expect(validator.validate([1, 2, 3]).isValid)
        #expect(validator.validate([]).isInvalid)
    }

    // MARK: - Each Validator Tests

    @Test func testEachValidatorAllValid() {
        let elementValidator = RangeValidator(range: 1...10)
        let validator = EachValidator<[Int], RangeValidator<Int>>(elementValidator: elementValidator)

        #expect(validator.validate([1, 5, 10]).isValid)
        #expect(validator.validate([2, 3, 4]).isValid)
    }

    @Test func testEachValidatorSomeInvalid() {
        let elementValidator = RangeValidator(range: 1...10)
        let validator = EachValidator<[Int], RangeValidator<Int>>(elementValidator: elementValidator)

        let result = validator.validate([1, 5, 15, 20])
        #expect(result.isInvalid)
        #expect(result.errors.count == 2)
    }

    @Test func testEachValidatorEmpty() {
        let elementValidator = RangeValidator(range: 1...10)
        let validator = EachValidator<[Int], RangeValidator<Int>>(elementValidator: elementValidator)

        #expect(validator.validate([]).isValid)
    }

    @Test func testEachValidatorWithContext() {
        let elementValidator = NotEmptyValidator()
        let validator = EachValidator<[String], NotEmptyValidator>(elementValidator: elementValidator)

        let result = validator.validate(["hello", "", "world", ""])
        #expect(result.isInvalid)
        #expect(result.errors.count == 2)
    }

    // MARK: - Unique Validator Tests

    @Test func testUniqueValidatorAllUnique() {
        let validator = UniqueValidator<[Int]>()

        #expect(validator.validate([1, 2, 3, 4, 5]).isValid)
        #expect(validator.validate([]).isValid)
        #expect(validator.validate([1]).isValid)
    }

    @Test func testUniqueValidatorHasDuplicates() {
        let validator = UniqueValidator<[Int]>()

        #expect(validator.validate([1, 2, 3, 2]).isInvalid)
        #expect(validator.validate([1, 1, 1]).isInvalid)
    }

    @Test func testUniqueValidatorStrings() {
        let validator = UniqueValidator<[String]>()

        #expect(validator.validate(["a", "b", "c"]).isValid)
        #expect(validator.validate(["a", "b", "a"]).isInvalid)
    }

    // MARK: - Contains Element Validator Tests

    @Test func testContainsElementValidatorFound() {
        let validator = ContainsElementValidator<[Int]>(element: 5)

        #expect(validator.validate([1, 2, 5, 8]).isValid)
        #expect(validator.validate([5]).isValid)
    }

    @Test func testContainsElementValidatorNotFound() {
        let validator = ContainsElementValidator<[Int]>(element: 5)

        #expect(validator.validate([1, 2, 3]).isInvalid)
        #expect(validator.validate([]).isInvalid)
    }

    // MARK: - All Satisfy Validator Tests

    @Test func testAllSatisfyValidatorAllTrue() {
        let validator = AllSatisfyValidator<[Int]>(
            message: "All numbers must be positive"
        ) { $0 > 0 }

        #expect(validator.validate([1, 2, 3]).isValid)
        #expect(validator.validate([5, 10, 15]).isValid)
    }

    @Test func testAllSatisfyValidatorSomeFalse() {
        let validator = AllSatisfyValidator<[Int]>(
            message: "All numbers must be positive"
        ) { $0 > 0 }

        #expect(validator.validate([1, -2, 3]).isInvalid)
        #expect(validator.validate([0, 1, 2]).isInvalid)
    }

    @Test func testAllSatisfyValidatorEmpty() {
        let validator = AllSatisfyValidator<[Int]>(
            message: "All numbers must be positive"
        ) { $0 > 0 }

        #expect(validator.validate([]).isValid)
    }

    // MARK: - Sorted Validator Tests

    @Test func testSortedValidatorAscending() {
        let validator = SortedValidator<[Int]>(order: .ascending)

        #expect(validator.validate([1, 2, 3, 4, 5]).isValid)
        #expect(validator.validate([1, 1, 2, 3]).isValid)
        #expect(validator.validate([]).isValid)
        #expect(validator.validate([5, 4, 3, 2, 1]).isInvalid)
        #expect(validator.validate([1, 3, 2]).isInvalid)
    }

    @Test func testSortedValidatorDescending() {
        let validator = SortedValidator<[Int]>(order: .descending)

        #expect(validator.validate([5, 4, 3, 2, 1]).isValid)
        #expect(validator.validate([3, 3, 2, 1]).isValid)
        #expect(validator.validate([1, 2, 3, 4, 5]).isInvalid)
        #expect(validator.validate([3, 1, 2]).isInvalid)
    }

    @Test func testSortedValidatorStrings() {
        let validator = SortedValidator<[String]>(order: .ascending)

        #expect(validator.validate(["alpha", "beta", "gamma"]).isValid)
        #expect(validator.validate(["gamma", "beta", "alpha"]).isInvalid)
    }

    // MARK: - Convenience Extension Tests

    @Test func testCollectionValidatorConvenience() {
        let countValidator: CountValidator<[Int]> = .count(1...5)
        let notEmptyValidator: CollectionNotEmptyValidator<[Int]> = .notEmpty

        #expect(countValidator.validate([1, 2, 3]).isValid)
        #expect(notEmptyValidator.validate([1]).isValid)
    }

    @Test func testHashableCollectionValidatorConvenience() {
        let uniqueValidator: UniqueValidator<[Int]> = .unique

        #expect(uniqueValidator.validate([1, 2, 3]).isValid)
        #expect(uniqueValidator.validate([1, 2, 1]).isInvalid)
    }

    @Test func testEquatableCollectionValidatorConvenience() {
        let containsValidator: ContainsElementValidator<[Int]> = .contains(5)

        #expect(containsValidator.validate([1, 5, 10]).isValid)
        #expect(containsValidator.validate([1, 2, 3]).isInvalid)
    }

    @Test func testComparableCollectionValidatorConvenience() {
        let sortedValidator: SortedValidator<[Int]> = .sorted()

        #expect(sortedValidator.validate([1, 2, 3]).isValid)
        #expect(sortedValidator.validate([3, 2, 1]).isInvalid)
    }
}
