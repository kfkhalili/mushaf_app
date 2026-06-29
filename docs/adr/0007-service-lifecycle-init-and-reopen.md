# 0007 — Service lifecycle: lazy init mixin + reopen-on-layout-change

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Reconstructed as-built (architecture reviews v1–v5)

## Context

Services wrap on-disk SQLite. Initialization is asynchronous (copy assets, open DBs, warm
static caches such as Juz/Hizb) and may be triggered concurrently from multiple providers,
so it must be **race-safe**. Switching the active mushaf layout must reopen the correct
layout/script DBs and release the previous ones without leaking connections.

## Decision

Every service mixes in `InitializationMixin` (`doInit()` / `markInitialized()` /
`ensureInitialized()`), which serializes initialization behind a shared `_initFuture`
rather than ad-hoc boolean flags. **Every public data method begins with
`await ensureInitialized()`**; housekeeping methods (`clearCache`, `close`) may skip it.
`DatabaseServiceNotifier` (`keepAlive`) `ref.watch`es `mushafLayoutSettingProvider`: on a
layout change it closes the previous service, builds a fresh `DatabaseService` for the new
layout, and registers an `onDispose` callback to clear the reference and close the service.

## Alternatives considered

- **Ad-hoc boolean `_initialized` flags** — race-prone under concurrent first calls;
  replaced by the `_initFuture` lock. Rejected.
- **Recreate all providers on layout change** — heavier and loses the targeted teardown;
  the notifier rebuild already scopes the reopen to the database service. Rejected.
- **Keep every layout's DBs open simultaneously** — wastes file handles/memory for layouts
  the user isn't viewing. Rejected.

## Consequences

**Positive:** race-safe single initialization; deterministic teardown; the correct DBs are
always open for the active layout; consumers just `await ...Provider.future`.

**Trade-offs / negative:** discipline required — forgetting `await ensureInitialized()` in
a new public method is a latent bug; switching layout incurs a close+reopen cost; the
previous service's `close()` must be awaited to avoid handle leaks.

## References

- `lib/utils/initialization_mixin.dart:17` — `ensureInitialized()` / `_initFuture` lock
- `lib/providers.dart:93` — `DatabaseServiceNotifier.build()` + `onDispose` reopen/close
- CLAUDE.md → "Service initialization", "Data flow"
