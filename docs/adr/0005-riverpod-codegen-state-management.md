# 0005 — Riverpod 3 with code generation as the sole state approach

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Reconstructed as-built (architecture reviews v1–v5)

## Context

The app needs dependency injection and reactive state for long-lived services (databases,
fonts, audio) and for per-page/per-ayah data, consistently across six platforms.
Hand-written provider boilerplate is error-prone, and mixing state solutions would
fragment the lifecycle model.

## Decision

Use **Riverpod 3.0 with code generation** as the single state-management approach. All
providers are declared in `lib/providers.dart` with `part 'providers.g.dart';` and the
generated file is rebuilt with `build_runner` after any provider change. Use
`@Riverpod(keepAlive: true)` for long-lived services and global state, and lowercase
`@riverpod` (auto-dispose) for page/data providers. Async services are consumed via
`await ref.watch(xProvider.future)`. Provider boilerplate is never hand-written. (The
*single-file* placement of providers is covered by [0006](0006-single-file-core-organization.md).)

## Alternatives considered

- **Hand-written Riverpod providers** — more boilerplate and easy to get the lifecycle
  annotations wrong. Rejected in favor of codegen.
- **Provider / Bloc / Redux / raw `setState`** — either less compile-time safety, more
  ceremony, or no shared async-service lifecycle. Rejected.

## Consequences

**Positive:** compile-time-safe provider references; minimal boilerplate; one consistent
lifecycle model with an explicit `keepAlive` (services) vs auto-dispose (data) split.
~30 `keepAlive` + ~27 auto-dispose providers follow this split today.

**Trade-offs / negative:** `build_runner` must run after editing provider declarations — a
stale `providers.g.dart` breaks the build, and CI regenerates it, so it won't be caught
locally unless regenerated; codegen adds a step to the dev loop and a learning curve.

## References

- `lib/providers.dart:28` — `part 'providers.g.dart';`
- `lib/providers.dart:93` — `DatabaseServiceNotifier` (`keepAlive` async service)
- `lib/providers.dart:131` — `pageData` (auto-dispose data provider)
- CLAUDE.md → "Riverpod state management", "Code generation"
