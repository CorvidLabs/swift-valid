---
module: valid
version: 1
status: stable
files:
  - Sources/Valid/Composition/AndValidator.swift
  - Sources/Valid/Composition/NotValidator.swift
  - Sources/Valid/Composition/OrValidator.swift
  - Sources/Valid/Core/AnyValidator.swift
  - Sources/Valid/Core/ValidationResult.swift
  - Sources/Valid/Core/Validator.swift
  - Sources/Valid/Schema/PropertyValidator.swift
  - Sources/Valid/Schema/Validatable.swift
  - Sources/Valid/ValidError.swift
  - Sources/Valid/Validators/CollectionValidation.swift
  - Sources/Valid/Validators/NumericValidation.swift
  - Sources/Valid/Validators/StringValidation.swift
db_tables: []
depends_on: []
---

# Valid

## Purpose

`Valid` is a synchronous, value-oriented Swift validation library. It represents success or one or more structured
errors, provides reusable validators for strings, numbers, and collections, and composes validators into schemas
without shared mutable state.

## Public API

### Exported Core and Composition

| API | Contract |
|-----|----------|
| `Validator` | `Sendable` protocol with associated `Value` and `validate(_:)`; extensions provide `and(_:)`, `or(_:)`, `not(error:)`, `not(message:)`, `eraseToAnyValidator()`, `isValid(_:)`, and `validateOrThrow(_:)`. |
| `ValidationResult` | `valid` or `invalid([ValidError])`; exposes `isValid`, `isInvalid`, `errors`, `and(_:)`, `or(_:)`, and `from(_:error:)` / `from(_:message:)`. |
| `ValidError` | Hashable, sendable error with `message`, `context`, `description`, and `field(_:message:)`. |
| `AnyValidator` | Sendable type erasure initialized from a validator or closure; provides `valid`, `invalid(error:)`, `invalid(message:)`, and `predicate(error:_:)` / `predicate(message:_:)`. |
| `AndValidator` | Evaluates both validators and combines their results with logical AND. |
| `OrValidator` | Evaluates both validators and combines their results with logical OR. |
| `NotValidator` | Converts wrapped success to the configured error and wrapped failure to success. |

### Exported Members

| API | Contract |
|-----|----------|
| `Value` | Associated or aliased validated value type used by validator conformances. |
| `init` | Constructs a validator or error from its documented configuration values. |
| `validate` | Evaluates a value and returns a `ValidationResult`. |
| `and` | Composes validators or results so both must succeed. |
| `or` | Composes validators or results so either may succeed. |
| `valid` | Represents success or constructs an always-successful type-erased validator. |
| `invalid` | Represents failure or constructs an always-failing type-erased validator. |
| `predicate` | Constructs type-erased validation from a sendable boolean predicate. |
| `isValid` | Reports whether validation succeeded. |
| `isInvalid` | Reports whether validation failed. |
| `errors` | Returns failure errors or an empty array for success. |
| `from` | Constructs a result from a boolean and an error or message. |
| `not` | Negates a validator with a caller-supplied error or message. |
| `eraseToAnyValidator` | Hides a concrete validator while preserving its value type and behavior. |
| `validateOrThrow` | Throws the first validation error and otherwise returns normally. |
| `buildBlock` | Composes one through six schema validators. |
| `build` | Executes a `SchemaBuilder` closure. |
| `property` | Creates key-path validation from a validator or sendable closure. |
| `validationErrors` | Returns the errors produced by self-validation. |
| `validator` | Wraps a `Validatable` type's instance method as `AnyValidator`. |
| `message` | Human-readable validation failure text. |
| `context` | Structured string metadata attached to a validation error. |
| `description` | Renders the message alone or with context key/value pairs. |
| `field` | Constructs a `ValidError` with a field context entry. |
| `exactly` | Constructs exact length or collection-count validation. |
| `minimum` | Constructs minimum length or collection-count validation. |
| `maximum` | Constructs maximum length or collection-count validation. |
| `SortOrder` | Direction selector for `SortedValidator`. |
| `count` | Constructs collection-count validation from a range or named bound. |
| `notEmpty` | Constructs string or collection non-empty validation. |
| `each` | Constructs per-element validation. |
| `allSatisfy` | Constructs collection predicate validation. |
| `unique` | Constructs hashable collection uniqueness validation. |
| `contains` | Constructs string-substring or collection-element containment validation. |
| `sorted` | Constructs collection ordering validation. |
| `ascending` | Selects nondecreasing sorted validation. |
| `descending` | Selects nonincreasing sorted validation. |
| `range` | Constructs comparable closed-range validation. |
| `min` | Constructs minimum-value validation. |
| `max` | Constructs maximum-value validation. |
| `positive` | Constructs positive or non-negative validation. |
| `negative` | Constructs negative or non-positive validation. |
| `even` | Constructs even-integer validation. |
| `odd` | Constructs odd-integer validation. |
| `multipleOf` | Constructs integer divisibility validation. |
| `length` | Constructs string length validation. |
| `notBlank` | Constructs whitespace-aware non-blank validation. |
| `email` | Constructs the library's email-pattern validation. |
| `pattern` | Constructs custom regular-expression validation. |
| `hasPrefix` | Constructs prefix validation. |
| `hasSuffix` | Constructs suffix validation. |

### Exported Schemas

| API | Contract |
|-----|----------|
| `PropertyValidator` | Reads a sendable root property by key path, validates it, and adds the configured `field` to every failure context. |
| `SchemaBuilder` | Result builder whose `buildBlock` overloads compose one through six root validators with AND. |
| `Schema` | Namespace with `build(_:)` and `property(_:fieldName:validator:)` / `property(_:fieldName:validate:)`. |
| `Validatable` | Self-validation protocol exposing `validate()`, `isValid`, `validationErrors`, `validateOrThrow()`, and `validator()`. |

### Exported String Validators

| API | Contract |
|-----|----------|
| `LengthValidator` | Accepts character counts in a closed range; `exactly(_:)`, `minimum(_:)`, and `maximum(_:)` create common ranges. |
| `NotEmptyValidator` | Rejects only an empty string. |
| `NotBlankValidator` | Rejects strings empty after trimming whitespace and newlines. |
| `EmailValidator` | Accepts the library's anchored local-part, domain, and two-or-more-letter suffix pattern. |
| `PatternValidator` | Uses `NSRegularExpression`; an invalid expression returns `Invalid regex pattern`. |
| `ContainsValidator` | Tests substring containment, optionally after lowercasing both strings. |
| `PrefixValidator` | Uses Swift prefix matching. |
| `SuffixValidator` | Uses Swift suffix matching. |
| String conveniences | `length(_:)`, `length(exactly:)`, `length(minimum:)`, `length(maximum:)`, `notEmpty`, `notBlank`, `email`, `pattern(_:message:)`, `contains(_:caseSensitive:)`, `hasPrefix(_:)`, and `hasSuffix(_:)`. |

### Exported Numeric Validators

| API | Contract |
|-----|----------|
| `RangeValidator` | Accepts values contained by a closed range. |
| `MinimumValidator` | Enforces an inclusive lower bound by default and a strict bound when `inclusive` is false. |
| `MaximumValidator` | Enforces an inclusive upper bound by default and a strict bound when `inclusive` is false. |
| `PositiveValidator` | Excludes zero by default; non-strict mode includes zero. |
| `NegativeValidator` | Excludes zero by default; non-strict mode includes zero. |
| `EvenValidator` | Tests binary integers with `isMultiple(of: 2)`. |
| `OddValidator` | Tests binary integers by negating `isMultiple(of: 2)`. |
| `MultipleOfValidator` | Tests a binary integer against its configured divisor. |
| Numeric conveniences | `range(_:)`, `min(_:inclusive:)`, `max(_:inclusive:)`, `positive(strict:)`, `negative(strict:)`, `even`, `odd`, and `multipleOf(_:)`. |

### Exported Collection Validators

| API | Contract |
|-----|----------|
| `CountValidator` | Accepts collection counts in a closed range; supports `exactly(_:)`, `minimum(_:)`, and `maximum(_:)`. |
| `CollectionNotEmptyValidator` | Rejects an empty collection. |
| `EachValidator` | Validates every element, preserves all failures, and adds the zero-based `index` to each error context. |
| `UniqueValidator` | Rejects hashable collections containing duplicate values. |
| `ContainsElementValidator` | Requires an equatable collection to contain the configured element. |
| `AllSatisfyValidator` | Requires every element to satisfy a sendable predicate and uses its configured failure message. |
| `SortedValidator` | Accepts empty and nondecreasing collections in `ascending` order or nonincreasing collections in `descending` order; `SortOrder` selects the direction. |
| Collection conveniences | `count(_:)`, `count(exactly:)`, `count(minimum:)`, `count(maximum:)`, `notEmpty`, `each(_:)`, `allSatisfy(message:_:)`, `unique`, `contains(_:)`, and `sorted(order:)`. |

## Invariants

1. A successful validation has no errors; a failed validation contains the errors produced by the failing validators.
2. AND evaluates both sides and accumulates both error arrays; OR succeeds when either side succeeds and otherwise accumulates both arrays.
3. Validator composition and type erasure preserve the validated `Value` type.
4. Property and element validators add location context without discarding existing error context.
5. All validators are synchronous and expose no mutable shared state.

## Behavioral Examples

- A username checked by `LengthValidator.minimum(3).and(NotBlankValidator())` succeeds only when both checks pass.
- `Schema.property(\.email, fieldName: "email", validator: EmailValidator())` reports failures with `context["field"] == "email"`.
- `EachValidator(elementValidator: PositiveValidator<Int>())` reports every invalid element with its array index.
- `SortedValidator<[Int]>(order: .descending)` accepts `[3, 3, 1]` and rejects `[3, 1, 2]`.
- Calling `validateOrThrow` throws the first `ValidError`; a valid value returns normally.

## Error Cases

| Condition | Behavior |
|-----------|----------|
| Invalid regular-expression source | `PatternValidator` returns one `ValidError` with `Invalid regex pattern`. |
| Invalid email | `EmailValidator` returns one `ValidError` with `Invalid email format`. |
| Multiple composed failures | AND and schema composition preserve all errors in evaluation order. |
| Negated validator succeeds | `NotValidator` returns the caller-provided error. |
| Empty ascending or descending collection | `SortedValidator` returns `valid`. |

## Dependencies

- Swift standard library protocols and collections.
- Foundation `NSRegularExpression`, `CharacterSet`, and string bridging for string validation.
- No runtime package dependencies.

## Change Log

| Date | Author | Change |
|------|--------|--------|
| 2026-07-13 | 0xLeif | Captured the existing Swift Valid 1.x contract for SpecSync 5 governance. |
