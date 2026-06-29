# 0002 — Multi-layout rendering via layout + script DBs, data-driven sizing

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Reconstructed as-built (commits `8e9ded7`, `a9188f3`; form-factor work)

## Context

The app supports multiple mushaf layouts that differ in page count, fonts, and word
script: Uthmani 15-line (604 pages), Indopak 13-line (849), Digital Khatt 15-line, and
Indopak 9-line (1890). The QUL layout family shares a **global word index** (≈83,668
words), so a new layout can reuse an existing script database and font rather than
shipping its own. Earlier, layout-specific logic was scattered across services, which
allowed a font/script mismatch that broke the 9-line layout.

## Decision

Model each render layout as a `MushafLayout` enum value. An extension maps each layout to
its **layout DB** and, via a font registry keyed by `info.font_name`, to its **script DB**
and font. Page count and page sizing are **read at runtime** from the layout's `info`
table (`getTotalPages()` → `info.number_of_pages`); the hardcoded `totalPages = 604` is
only a fallback when the `info` read fails. `indopak9Lines` deliberately reuses the
Digital Khatt / Indopak script DB and font through the registry. Adding a layout is
therefore a **data-driven** change: map the enum to its DBs and reuse a script/font spec.

## Alternatives considered

- **Hardcode 604 pages and assume a single Uthmani layout** — cannot express Indopak
  (849) or 9-line (1890); rejected once multiple layouts shipped.
- **Per-layout branching scattered through services** — the previous approach; allowed
  font and script DBs to drift out of sync (the 9-line bug). Rejected in favor of a single
  enum + registry that structurally couples a layout's font and script.

## Consequences

**Positive:** new layouts are added declaratively (enum → DBs, reuse script/font spec);
font/script divergence is prevented by construction; varying page counts are handled
uniformly; sizing is authored in the data, not the code.

**Trade-offs / negative:** more indirection (enum extension + font registry); requires
every bundled layout DB to carry a correct `info` table; runtime reads need sensible
fallbacks for corrupt/missing `info` rows.

## References

- `lib/constants.dart:43` — `MushafLayout` enum + layout/script DB mapping + font registry
- `lib/services/database_service.dart:106` — caches `info.number_of_pages` at init
- `lib/services/database_service.dart:1020` — `getTotalPages()` (fail rather than wrong 604)
- `docs/active/form-factor-page-layout.md` — DB-driven page sizing
- Auto-memory: "QUL layout word-id alignment"
