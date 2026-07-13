---
spec: valid.spec.md
---

## Automated Testing

| Test File | Requirements | What It Covers |
|-----------|--------------|----------------|
| `CompositionTests.swift` | REQ-valid-001, REQ-valid-002, REQ-valid-003, REQ-valid-004, REQ-valid-010 | Result combination, type erasure, predicates, negation, and throwing. |
| `SchemaTests.swift` | REQ-valid-002, REQ-valid-005, REQ-valid-010 | Property context, one-to-six-field schema composition, and `Validatable`. |
| `StringValidationTests.swift` | REQ-valid-001, REQ-valid-006 | String boundaries, email, regex, containment, prefix, and suffix behavior. |
| `NumericValidationTests.swift` | REQ-valid-001, REQ-valid-007 | Numeric bounds, signs, parity, divisibility, and convenience factories. |
| `CollectionValidationTests.swift` | REQ-valid-001, REQ-valid-008, REQ-valid-009 | Count, emptiness, each/index context, uniqueness, containment, predicates, and ordering. |

## Manual Testing

No manual runtime flow exists. Run `swift test` and the strict SpecSync check from a clean checkout.

## Edge Cases & Boundary Conditions

| Scenario | Expected Behavior |
|----------|-------------------|
| Both AND operands fail | Both error arrays are preserved in operand order. |
| Both OR operands fail | Both error arrays are preserved in operand order. |
| Empty collection sort check | Validation succeeds for either order. |
| Non-strict sign validator receives zero | Validation succeeds. |
| Invalid regex pattern | Validation fails without throwing. |
