---
id: CHG-0002-document-the-existing-swift-valid-api-at-complete-coverage-and-correct-rollout-p
state: accepted
type: documentation
base_commit: 51ad66b540c2f5fd14a7acfc7f0ef2ff4e8d25a0
---

# Document the existing Swift Valid API at complete coverage and correct rollout policy gaps

## Intent

Document the existing Swift Valid API at complete coverage and correct rollout policy gaps

## Affected Canonical Specs

- `valid`

## Acceptance Criteria

- A stable canonical Valid specification maps every Swift implementation file and every exported declaration.
- Strict SpecSync passes at 100 percent file, line, and export coverage.
- The committed Trust policy blocks lifecycle warnings and requires 100 percent contract coverage.
- README and governance policy files require an SDD change.
- All four agent integrations are current.
- The native build, complete test suite, hosted Trust gate, and CodeQL pass.

## No-spec Rationale

Not applicable
