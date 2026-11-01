---
change: run-the-specsync-archive-gate-before-every-ci-job
artifact: testing
---

# Testing

- Each edited workflow parses with
  `ruby -e 'require "psych"; Psych.safe_load(File.read(ARGV[0]))'`, and printing
  every job's `needs` shows `archive-gate` with none, `build`, `macOS`, `trust`
  and `ubuntu` needing `archive-gate`, and `deploy` needing `build`.
- `bash .github/scripts/archive-readiness.sh .` from CorvidLabs/spec-sync run
  against this repository fails while changes are open, which is the behavior the
  Archive job relies on.
- In CI, the Archive check runs on this pull request and every other job waits
  for it; it passes only once every change under `.specsync/changes/` is
  archived.
