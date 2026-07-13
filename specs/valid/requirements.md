---
spec: valid.spec.md
---

# Requirements

### REQ-valid-001

Every validator SHALL return `ValidationResult.valid` or `ValidationResult.invalid` with structured `ValidError` values.

Acceptance Criteria

- Successful validation exposes an empty `errors` array.
- Failed validation exposes the errors supplied by the failing validator.

### REQ-valid-002

Composition SHALL implement AND and OR without discarding failures.

Acceptance Criteria

- AND evaluates both validators and accumulates both failure arrays.
- OR succeeds when either validator succeeds and otherwise accumulates both failure arrays.

### REQ-valid-003

Negation SHALL invert wrapped validity and use the configured error for an inverted failure.

Acceptance Criteria

- A wrapped failure becomes valid.
- A wrapped success becomes invalid with exactly the configured error.

### REQ-valid-004

Type erasure and composition SHALL preserve the validated value type and sendable behavior.

Acceptance Criteria

- `AnyValidator` accepts a same-`Value` validator or sendable closure.
- Composed validators require matching `Value` types.

### REQ-valid-005

Schema property validation SHALL attach the configured field name without removing existing error context.

Acceptance Criteria

- Every property failure contains `context["field"]`.
- Existing context keys remain present unless they were already named `field`.

### REQ-valid-006

String validators SHALL enforce their documented length, whitespace, email, regex, containment, prefix, and suffix predicates.

Acceptance Criteria

- Valid inputs return `valid` and invalid inputs return one descriptive error.
- Invalid regex source returns `Invalid regex pattern` without throwing.

### REQ-valid-007

Numeric validators SHALL enforce configured ranges, bounds, signs, parity, and divisibility.

Acceptance Criteria

- Inclusive and exclusive bounds differ only at the configured boundary.
- Strict sign checks reject zero while non-strict checks accept zero.

### REQ-valid-008

Collection validators SHALL enforce configured count, emptiness, element, uniqueness, containment, predicate, and sort-order constraints.

Acceptance Criteria

- Empty collections are valid for either sorted order.
- Duplicate, missing-element, predicate, and ordering failures are reported as invalid.

### REQ-valid-009

Element validation SHALL preserve all failures and record each failing element's zero-based index.

Acceptance Criteria

- Every element is evaluated.
- Each propagated failure contains the enumerated element index.

### REQ-valid-010

Throwing validation helpers SHALL return normally for valid input and throw the first validation error for invalid input.

Acceptance Criteria

- Valid input does not throw.
- Invalid input throws the first `ValidError` in its result.

## Constraints

- Public validation APIs are synchronous and `Sendable` under Swift 6.
- The package supports the Apple platform minimums declared in `Package.swift`.
- Regex behavior is Foundation `NSRegularExpression` behavior.

## Out of Scope

- Network, persistence, UI, localization, and asynchronous validation.
- Changing existing validator behavior as part of this governance migration.
