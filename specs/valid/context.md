---
spec: valid.spec.md
---

## Key Decisions

- Treat `ValidationResult` and `ValidError` as the shared result model for every validator.
- Prefer generic, sendable value validators and protocol composition over inheritance.
- Preserve all AND/schema errors so callers can present complete validation feedback.

## Files to Read First

- `Sources/Valid/Core/Validator.swift`
- `Sources/Valid/Core/ValidationResult.swift`
- `Sources/Valid/Schema/PropertyValidator.swift`
- `Sources/Valid/Validators/StringValidation.swift`

## Current Status

The documented behavior is implemented and protected by the five Swift Testing suites. This specification records
existing behavior only; the rollout does not modify `Sources/` or `Tests/`.

## Notes

String regular expressions rely on Foundation. Collection validator error ordering follows collection enumeration and
the order in which composed validators are evaluated.
