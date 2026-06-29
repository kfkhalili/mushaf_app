# 0008 — Defense-in-depth data validation & SQL safety posture

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Reconstructed as-built (security audits v1–v7)

## Context

Even bundled, curated data can be `null`, mistyped, or out of range, and some queries
incorporate user-influenced input (search). Seven security audits established a consistent
posture: a single validation layer is never enough for critical operations, and "the data
is from our own DB, so it's safe" is not an assumption the code is allowed to make.

## Decision

Apply **defense in depth**:

- **Validate at service boundaries** — including data read from the trusted bundled DBs —
  using the centralized `validate*` helpers (`validateSurahNumber`, `validatePageNumber`,
  `validateSearchQuery`, `validateFilePath`, `validateDatabaseFileName`, …). Parsing
  success ≠ valid range.
- **Parse defensively** — dynamic→int only via `parseInt()`, never `int.parse()`; cast to
  nullable with explicit null checks; skip invalid rows or return safe defaults.
- **Parameterize all SQL** — `?` placeholders + `whereArgs` (including `LIKE`), with
  `DbConstants` for every table/column name. Never interpolate values.
- **Whitelist & sandbox file access** — DB filenames checked against a whitelist; paths
  validated against the documents dir to block traversal.
- **Fail safe, don't leak** — non-critical errors return safe defaults (`''`, `0`),
  critical ones throw custom exceptions; never surface DB paths or stack traces to users.

## Alternatives considered

- **Trust curated DB data and validate only user input** — one bad/corrupt row then
  crashes or corrupts state. Rejected; the audits treat all data as untrusted.
- **Inline ad-hoc validation per call site** — drifts and is easy to forget. Rejected in
  favor of centralized `validate*` helpers.
- **String-interpolated SQL** — injection vector. Rejected; parameterized everywhere.

## Consequences

**Positive:** resilient to corrupt/missing data; no SQL-injection surface; uniform
safe-default behavior; no sensitive leakage in errors or logs.

**Trade-offs / negative:** validation boilerplate at every boundary; safe-defaults can
**mask** underlying data problems (mitigated by `kDebugMode`-gated `debugPrint`).

## References

- `lib/utils/validation_helpers.dart:51` — bounded `validate*` helpers
- `lib/utils/parsing_helpers.dart:19` — `parseInt()` safe parse
- `lib/services/bundled_database_store.dart:57` — filename whitelist + path guard
- `docs/archived/security_audits/` — audits v1–v7
- CLAUDE.md → "Security & data validation"
