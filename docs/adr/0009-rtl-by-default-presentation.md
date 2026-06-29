# 0009 — RTL-by-default via explicit `Directionality`

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Reconstructed as-built

## Context

The app presents Arabic scripture and an Arabic-first UI. Text direction and layout must
be **right-to-left regardless of the device locale** — a user with an LTR system language
must still get a correctly mirrored mushaf.

## Decision

Force RTL explicitly rather than inheriting it from the device locale. The widget tree is
wrapped in `Directionality(textDirection: TextDirection.rtl)` at the root in `main.dart`,
and **every screen** re-wraps its `SafeArea`/root in `Directionality.rtl` (including the
shared `BaseScreen` used by most screens) so top-level widgets like `AppHeader` inherit RTL
correctly. Positioning uses `Align`/`Padding` rather than hardcoded left/right so layouts
flip correctly.

## Alternatives considered

- **Locale-driven directionality** (let Flutter pick from the system locale) — would render
  LTR for users whose device locale is not an RTL language, breaking the mushaf layout.
  Rejected.

## Consequences

**Positive:** guaranteed RTL everywhere, independent of system settings; top-level chrome
inherits the correct direction.

**Trade-offs / negative:** some screens end up with redundant nested `Directionality`
wrappers (harmless); contributors must remember to wrap each **new** screen's root, since
there is no single enforced choke point.

## References

- `lib/main.dart:57` — root `Directionality(TextDirection.rtl)`
- `lib/widgets/shared/base_screen.dart:44` — per-screen RTL wrap
- CLAUDE.md → "RTL"
