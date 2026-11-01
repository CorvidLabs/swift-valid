---
change: run-the-specsync-archive-gate-before-every-ci-job
artifact: context
---

# Context

This is part of the org-wide rollout of CorvidLabs/spec-sync#832, approved by
0xLeif. That pull request (merged as 106aaa43d0bcf049f19b173ddb63815a25c3f931)
added an archive gate to the spec-sync GitHub Action: with
`archive-gate-only: 'true'` it runs only `.github/scripts/archive-readiness.sh`
(bash and python3, no binary download) and fails while any change under
`.specsync/changes/` is still open. The goal is that every SpecSync change is
archived before a pull request merges, and that CI runs nothing else until it is.

Published spec-sync tags up to and including v6.1.1 ignore the new input, so the
step pins the merge commit instead of a tag. It should move to the first release
that ships the gate.

Branch protection, through an org ruleset that requires a check named Archive, is
configured separately and is not part of this change. A skipped job counts as
passing, so merge blocking relies on that ruleset.

When this change was created, `CHG-0001-...` and `CHG-0002-...` were already open
on `main` (accepted, legacy v1 workflow, with stale acceptance evidence). This
change does not touch them; the Archive check stays red until their owners
archive them.
