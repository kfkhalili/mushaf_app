# 0004 — 604 page-specific fonts: lazy, uncached in pubspec, fail-loud

- **Status:** Accepted
- **Date:** 2026-06-30
- **Deciders:** Reconstructed as-built

## Context

Authentic Uthmani rendering uses **604 page-specific fonts** — one font per page — so each
page's glyphs match the printed mushaf exactly. Declaring 604 font families in
`pubspec.yaml` would bloat the asset manifest and load everything eagerly. For Quran text,
rendering the **wrong** glyphs (via a fallback font) is worse than showing a clear error.

## Decision

Load page fonts **lazily at runtime** via `FontLoader`, caching the loaded family by
`'${layout.name}_$pageNumber'` in an **LRU-bounded** cache (max ~50 fonts). The 604 fonts
are **not declared in `pubspec.yaml`**; the font directory is bundled as an asset and the
files are loaded on demand. There is **no fallback font** for Quran text: a failed
page-font load throws `FontException` and surfaces the error — it must never silently
substitute another font. Indopak uses a single declared font for all pages; surah names
and the Basmallah render from predeclared glyph fonts.

## Alternatives considered

- **Declare all 604 fonts in `pubspec.yaml`** — heavy asset manifest and eager loading of
  fonts the user may never view. Rejected.
- **One app-wide Quran font** — loses the per-page authenticity that is the product's core
  value. Rejected.
- **System/Arabic-font fallback on load failure** — would silently render incorrect or
  garbled scripture and hide font-registry mismatches. Rejected; fail-loud instead.

## Consequences

**Positive:** bounded memory via LRU cache; authentic per-page glyphs; fail-loud behavior
catches font/script registry mismatches (see [0002](0002-multi-layout-rendering-abstraction.md))
early instead of shipping wrong text.

**Trade-offs / negative:** fonts must be loaded before paint, so font loading is async and
flows through a provider; LRU eviction can force a re-load when revisiting a page; a
missing asset hard-fails that page rather than degrading gracefully (by design).

## References

- `lib/services/font_service.dart:22` — lazy load + LRU cache keyed by `layout_page`
- `lib/services/font_service.dart:48` — throws `FontException` (no fallback)
- `lib/exceptions/database_exceptions.dart:76` — `FontException`
- `pubspec.yaml:117` — only common/declared fonts; page fonts loaded dynamically (see note at :130)
- CLAUDE.md → "Fonts"
