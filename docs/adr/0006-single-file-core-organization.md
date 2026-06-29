# 0006 — Centralized "single-file core" code organization

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Reconstructed as-built

## Context

Riverpod code generation works best when providers live together with a single
`part` directive, and the team values discoverability ("where do I find the constant /
model / provider?"). Most Flutter apps instead scatter these across feature folders.

## Decision

Keep the top-level state and configuration in **flat single files**, not directories:

- `lib/constants.dart` — all constants (`DbConstants`, layout enum, sizing, magic numbers).
- `lib/models.dart` — core immutable data models.
- `lib/providers.dart` — every Riverpod provider (no `lib/providers/` directory).
- `lib/themes.dart` — the theme builders.

Domain-heavy model clusters may live in their own files — `lib/models/ontology_models.dart`
and `lib/memorization/models.dart` — as a **deliberate domain split**, not a violation. The
rule is "centralize the core; split only by clearly bounded domain."

## Alternatives considered

- **Conventional feature-folder structure** (`lib/features/<x>/{models,providers,...}`) —
  better isolation per feature, but fragments the codegen `part` files and makes
  cross-cutting constants/models harder to locate. Rejected for the core; allowed only as
  the bounded-domain exception above.

## Consequences

**Positive:** one obvious source per concern; simple codegen part-files; trivial to grep
and discover; no `providers/` sprawl.

**Trade-offs / negative:** large hot files (`providers.dart` ≈ 1.4k lines) raise the
merge-conflict surface; the "single file" rule has documented exceptions that newcomers
must learn, or they'll wrongly "fix" the domain-split files into the monolith.

## References

- `lib/constants.dart`, `lib/models.dart`, `lib/providers.dart`, `lib/themes.dart`
- `lib/models/ontology_models.dart`, `lib/memorization/models.dart` — domain-split exceptions
- CLAUDE.md → "Single-file core (intentional, for codegen + discoverability)"
