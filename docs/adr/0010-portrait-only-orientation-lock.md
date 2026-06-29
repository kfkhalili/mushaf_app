# 0010 — Portrait-only orientation lock (temporary)

- **Status:** Accepted (temporary — revisit when chrome is form-factor adaptive)
- **Date:** 2026-06-30
- **Deciders:** Reconstructed as-built (form-factor / page-layout work)

## Context

The current chrome — headers, dialogs, and the page layout itself — is **not yet
form-factor adaptive**. Allowing landscape or large form factors today would break the
mushaf page rendering and surrounding UI.

## Decision

Lock the app to portrait at startup in `main.dart`
(`SystemChrome.setPreferredOrientations([portraitUp, portraitDown])`). This is an
**explicitly temporary** constraint: the lock is to be removed once the chrome and page
layout become form-factor adaptive, tracked in `docs/active/form-factor-page-layout.md`.
The in-code comment records the same exit condition.

## Alternatives considered

- **Support landscape / adaptive orientation now** — premature; the layout and chrome are
  not ready, so it would ship a broken experience on rotation and on tablets. Rejected
  until the adaptive work lands.

## Consequences

**Positive:** a stable, correct layout on phones today; no rotation-induced breakage.

**Trade-offs / negative:** no tablet/landscape support yet; this decision is intentionally
time-boxed and **must be revisited** — leaving the lock in place after the adaptive work
lands would be a regression in scope, not a deliberate choice.

## References

- `lib/main.dart:18` — orientation lock + rationale comment (exit condition)
- `docs/active/form-factor-page-layout.md` — the adaptive-layout track that retires this
