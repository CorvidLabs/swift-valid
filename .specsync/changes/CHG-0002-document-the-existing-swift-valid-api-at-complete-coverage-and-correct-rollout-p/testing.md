---
change: CHG-0002-document-the-existing-swift-valid-api-at-complete-coverage-and-correct-rollout-p
artifact: testing
---

# Testing

The native verification lane runs `swift build -v` and `swift test -v`. The 109 tests in five suites provide the
following requirement evidence:

- `CompositionTests.swift`: REQ-valid-001, REQ-valid-002, REQ-valid-003, REQ-valid-004, REQ-valid-010.
- `SchemaTests.swift`: REQ-valid-002, REQ-valid-005, REQ-valid-010.
- `StringValidationTests.swift`: REQ-valid-001, REQ-valid-006.
- `NumericValidationTests.swift`: REQ-valid-001, REQ-valid-007.
- `CollectionValidationTests.swift`: REQ-valid-001, REQ-valid-008, REQ-valid-009.

Strict SpecSync additionally must report all twelve implementation files, every source line, and all 85 distinct
export symbols documented before the change can close.
