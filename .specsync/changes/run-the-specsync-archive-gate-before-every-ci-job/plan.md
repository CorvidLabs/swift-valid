---
change: run-the-specsync-archive-gate-before-every-ci-job
artifact: plan
---

# Plan

## Approach

Add a first job, `archive-gate` with display name `Archive`, to every workflow
that triggers on `pull_request` or `push`, and make every other job depend on it.
The job checks out the pull request head (or the pushed commit) without persisted
credentials and runs `CorvidLabs/spec-sync@106aaa43d0bcf049f19b173ddb63815a25c3f931`
with `archive-gate-only: 'true'` on `ubuntu-latest`.

## Out of scope

- Archiving, reopening or otherwise changing the changes already open on `main`.
- Configuring the org ruleset that requires the Archive check.
- Changing the SpecSync version the trust workflow pins, or any build, test or
  documentation step.

## Steps

1. In `docs.yml`, `macOS.yml`, `trust.yml` and `ubuntu.yml`, insert the
   `archive-gate` job at the top of `jobs:` using the same `actions/checkout@v5`
   the workflow already uses.
2. Add `needs: archive-gate` to every job without `needs` (`build`, `macOS`,
   `trust`, `ubuntu`); `deploy` already needs `build` and reaches the gate
   transitively.
3. Confirm each file parses and print each job's `needs`.

## Risks

- Every pull request is blocked while any change is open, including changes
  opened by others; this is intended.
- The action is pinned to a commit on `main` rather than a release; move the pin
  to the first release that includes the gate.
- Jobs skipped because the gate failed count as passing, so the org ruleset must
  require the Archive check for merges to be blocked.

## Constraints consulted

- AGENTS.md: do not approve or close an SDD change on behalf of a human owner
  (this change stops before approval; 0xLeif records approval and review).
- AGENTS.md: preserve macOS, Ubuntu, public API and independent DocC Pages
  boundaries (those jobs are unchanged apart from depending on the gate).
- `.trust.toml` remains the policy authority; it is not edited.
