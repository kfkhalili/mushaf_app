# 0001 — Offline-first: bundled read-only SQLite, no backend

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Reconstructed as-built (architecture reviews v1–v5)

## Context

`mushaf_app` renders the Quran (604+ pages) with authentic typography plus search,
tafsir, a topic/ontology explorer, recitation metadata, and more. The content is **fixed,
curated, and large**, spanning several data domains (layout, word script, metadata,
tafsir, topics, recitation). A mushaf must work fully offline, and the data essentially
never changes between releases. The app targets six platforms (iOS, Android, web, macOS,
Windows, Linux).

## Decision

Ship **all Quran content as read-only SQLite databases** bundled under `assets/db/`. At
startup each DB is copied from the asset bundle into the app documents directory (skipped
if the destination already exists), then opened **read-only** via `sqflite`. This logic is
centralized in `BundledDatabaseStore`, which validates every filename against a whitelist
(`bundledDatabaseFileNames`) and guards the destination path against traversal before
touching the filesystem. There is **no backend** and no network dependency for content.

## Alternatives considered

- **Bundled JSON / asset files** — no indexed queries, higher memory and parse cost, and
  no relational joins across the metadata/script/layout domains. Rejected.
- **REST/GraphQL backend** — requires connectivity, server infrastructure, sync, and
  ongoing cost for content that is static and must be available offline. Rejected: a
  mushaf that needs the network to render is unacceptable.
- **On-device generation of layout/script data** — duplicates curation logic on the
  client and risks divergence from the authored source. Rejected.

## Consequences

**Positive:** fully offline; fast indexed SQL queries; zero infrastructure or running
cost; content integrity guaranteed by shipping curated DBs; read-only open prevents
accidental mutation of source data.

**Trade-offs / negative:** large app binary (many bundled DBs + fonts); content updates
require an app release; copy-on-first-launch adds startup latency and disk usage; because
the bundled DBs are read-only, **user-generated data needs a separate writable store**
(see [0003](0003-unified-app-data-db.md)).

## References

- `lib/services/bundled_database_store.dart:37` — `open()` (copy-if-needed, read-only open)
- `lib/services/bundled_database_store.dart:57` — filename whitelist + path-traversal guard
- `lib/constants.dart:24` — `bundledDatabaseFileNames` whitelist
- `lib/services/database_service.dart:90` — opens four bundled DBs per layout
- CLAUDE.md → "Databases"
