# Architecture Decision Records (ADRs)

This directory records the **load-bearing architectural decisions** of `mushaf_app` —
choices that involved a genuine fork in the road and have lasting consequences. An ADR
captures the *context*, the *decision*, the *alternatives that were rejected*, and the
*consequences* — the "why is it this way?" a future contributor will ask.

These ADRs are largely **retroactive ("as-built")**: the decisions were made and shipped
before the records existed, and were reconstructed from the code plus the existing
architecture reviews, security audits, and planning docs. They are marked `Accepted`.

## What belongs here vs. CLAUDE.md

- **ADR** — a structural decision with real alternatives (e.g. "offline-first bundled
  SQLite, no backend"). Recording the rejected option is the point.
- **CLAUDE.md** — coding conventions and style rules with no architectural fork
  (e.g. `debugPrint` over `print`, `Equatable` for equality, member ordering). These are
  *how we write code*, not *decisions about the system's shape*. Do not duplicate them here.

## Index

| ADR | Title | Status |
|-----|-------|--------|
| [0001](0001-offline-first-bundled-sqlite.md) | Offline-first: bundled read-only SQLite, no backend | Accepted |
| [0002](0002-multi-layout-rendering-abstraction.md) | Multi-layout rendering via layout + script DBs, data-driven sizing | Accepted |
| [0003](0003-unified-app-data-db.md) | Unified writable `app_data.db` for user data + migration | Accepted |
| [0004](0004-page-specific-fonts-lazy-failloud.md) | 604 page-specific fonts: lazy, uncached in pubspec, fail-loud | Accepted |
| [0005](0005-riverpod-codegen-state-management.md) | Riverpod 3 with code generation as the sole state approach | Accepted |
| [0006](0006-single-file-core-organization.md) | Centralized "single-file core" code organization | Accepted |
| [0007](0007-service-lifecycle-init-and-reopen.md) | Service lifecycle: lazy init mixin + reopen-on-layout-change | Accepted |
| [0008](0008-defense-in-depth-data-validation.md) | Defense-in-depth data validation & SQL safety posture | Accepted |
| [0009](0009-rtl-by-default-presentation.md) | RTL-by-default via explicit `Directionality` | Accepted |
| [0010](0010-portrait-only-orientation-lock.md) | Portrait-only orientation lock (temporary) | Accepted |

## Adding a new ADR

1. Copy the template below into `NNNN-short-title.md` (next free 4-digit number).
2. Fill every section. If the decision **supersedes** or **refines** an earlier ADR,
   say so in both ADRs (`Supersedes: 0003` / `Superseded by: 0011`).
3. Add a row to the index above.
4. Keep the status accurate: `Proposed` → `Accepted` → (`Deprecated` | `Superseded`).

### Template (MADR-style)

```markdown
# NNNN — <decision in a short noun phrase>

- **Status:** Proposed | Accepted | Deprecated | Superseded by <ADR>
- **Date:** YYYY-MM-DD
- **Deciders:** <who / which review>

## Context

What forces are at play? What problem or constraint prompts a decision?

## Decision

The choice, stated plainly. What we do, and the rule contributors must follow.

## Alternatives considered

- **<Option>** — why rejected.

## Consequences

**Positive:** …
**Trade-offs / negative:** …

## References

Code anchors (`file.dart:line`) and the prior docs that deliberated this.
```
