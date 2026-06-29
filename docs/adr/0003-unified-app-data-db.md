# 0003 — Unified writable `app_data.db` for user data + one-time migration

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Reconstructed as-built (storage consolidation plan)

## Context

User-generated data was spread across **three incompatible storage mechanisms**:
`bookmarks.db` (SQLite), `reading_progress.db` (SQLite), and an in-memory `Map` for
memorization sessions that was **lost on every app restart**. This created inconsistent
APIs, a data-loss bug, and extra maintenance surface. The bundled content DBs are
read-only (see [0001](0001-offline-first-bundled-sqlite.md)), so writable user data needs
its own home.

## Decision

Consolidate **all writable user data into a single `app_data.db`** (`sqflite`, versioned,
`singleInstance`) with tables for memorization sessions, bookmarks, reading sessions, and
user preferences. Keep `SharedPreferences` **only** for lightweight preferences that must
be read synchronously before `ProviderScope` initializes (theme mode, last page). A
one-time `MigrationService`, gated by the `SharedPreferences` flag `app_data_migrated_v1`,
atomically copies the legacy `bookmarks.db` and `reading_progress.db` into `app_data.db`
within a transaction; it no-ops on fresh installs and never re-runs.

## Alternatives considered

- **Keep separate per-feature databases** — multiple connections, duplicated init/storage
  code, and no shared transactional consistency. Rejected.
- **Keep memorization in memory** — the source of the data-loss bug. Rejected.
- **Move everything to `SharedPreferences`** — wrong tool for structured, queryable,
  growing user data. Rejected; `SharedPreferences` retained only for startup-critical
  scalars.

## Consequences

**Positive:** one connection pool and one storage API; memorization sessions now persist;
easier backup and a clear path to future cloud sync; consistent service-layer access.

**Trade-offs / negative:** migration must be **idempotent** and transactional; one
schema/version to manage going forward; legacy DB files are intentionally left in place
until a later release deems removal safe.

## References

- `lib/services/app_data_service.dart:7` — unified DB open + table creation
- `lib/services/migration_service.dart:20` — flag-gated, transactional one-time migration
- `docs/archived/planning/storage_consolidation_plan.md` — §3.3 "Architecture Decision:
  Keep SharedPreferences?" (the original deliberation)
