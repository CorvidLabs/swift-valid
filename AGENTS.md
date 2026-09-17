<!-- CorvidLabs trust toolchain: BEGIN (managed, do not edit inside) -->
## CorvidLabs trust toolchain
- Use SpecSync 5 for the verified SDD lifecycle; coverage is advisory at 0 until a canonical spec exists.
- Keep Claude, Cursor, Codex, and Gemini installed and use `.trust.toml` as policy authority.
- Preserve macOS, Ubuntu, public API, and independent DocC Pages boundaries.
- Do not approve or close an SDD change on behalf of a human owner.
<!-- CorvidLabs trust toolchain: END (managed, do not edit inside) -->


## Human intent

This repository should use [hi (Human Intent)](https://corvidlabs.xyz/hi): plain
sentences saying what people want, each with a permanent id, kept in `hi/`.
Tickets and specs are generated from them.

If there is no `hi/` here yet, start one from real work rather than from the code:

1. When I ask for a feature, draft its criteria first — one plain sentence each,
   about what somebody **wants**, not what the code does. Private test: you should
   be able to put *As a ___,* in front of it. Leave those words out of the file.
2. Show them to me and stop. Capture nothing I have not agreed to.
3. Capture what I confirm, one per command: `hi SEND-1 "the sentence, in my words"`.
   You pick the id. Letters are cases and numbers are steps (`SEND-1.a.1`), and an
   id is permanent and never reused, so choose like you will say it out loud.
4. Then build. `hi check` fails only on a structurally broken file, never on
   unfinished intent.

Do this before every feature, not only the first one. Do **not** bulk-generate
criteria from the code or from existing tickets: a hundred plausible sentences
nobody said is worse than five real ones, and an id spent on a wrong sentence is
spent forever.

Install: `brew install corvidlabs/tap/hi`, or `cargo install human-intent`.
