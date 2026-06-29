# Form-Factor Page Layout (DB-Driven Grid)

**Last Updated**: 2026-06-29
**Status**: Phase 1 landed (reading-surface body sizing). Phases 2+ open.

---

## Problem

The Mushaf reading surface was sized by **hardcoded, phone-tuned magic numbers**
rather than by the layout the database actually dictates:

- `mushaf_line.dart` computed the body font size as
  `userFontSize × min(screenWidth / 428, screenHeight / 926)`, then
  `clamp(16, 30)` — a single linear scale off one phone reference
  (`referenceScreenWidth = 428`, `referenceScreenHeight = 926`).
- The page's vertical layout was an **emergent side-effect** of that font size:
  `Column(center)` stacked lines whose height was `fontSize × layoutLineHeights`
  (a magic `2.1`). Whether 15 lines filled the page was a coincidence of the
  tuned constants, not a derived fact.
- Off the 428×926 reference (tablet, desktop window, web, split-screen) the
  `clamp(16, 30)` capped the font, the rows no longer filled the height, and the
  block floated in dead space (or risked overflow).

The deepest issue: **`lines_per_page` — the database's single most important
layout value — was read but never used to lay out a page.** It reached
`getLayoutInfo()` and was only displayed as informational text in settings. The
renderer reverse-engineered a height from a font scale instead of consuming the
grid the DB hands it.

## The database is the layout contract

Each of the four layout databases (`uthmani-15-lines`, `indopak-13-lines`,
`digital-khatt-15-lines`, `indopak-9-lines`) shares one schema where **each row
is one line**:

```sql
pages(page_number, line_number, line_type, is_centered, first_word_id, last_word_id, surah_number)
info (name, number_of_pages, lines_per_page, font_name)
```

What the DB **fixes** (immutable, authored):

| Value | Examples | Layout consequence |
| --- | --- | --- |
| `lines_per_page` | 15 / 13 / 15 / 9 | The page is a fixed N-row grid; vertical rhythm is not free. |
| actual rows on a page | pages 1–2 = 8 (or 7 for 9-line) | The decorative opening spread is encoded as *fewer rows*, not styling. |
| `line_type` | `ayah` / `surah_name` / `basmallah` | Each row's role is fixed. |
| `is_centered` | per line, 0 = justified / 1 = centered | Per-line alignment is authored. |
| `first_word_id..last_word_id` | word range per line | Line breaks are frozen; the page cannot reflow. |
| `font_name` | `me_quran`, `digitalkhatt`, … | The page-authored font the layout expects. |

Pagination is **shared by layout, not universal**: Uthmani-15 and Digital
Khatt-15 are the same 604-page Madani pagination (identical page structure,
different font); Indopak-13 (849 pages) and Indopak-9 (1890 pages) are
independent. They diverge as early as page 1 (line count) and page 2 (content).
So no page-number can be special-cased — even "pages 1–2 are the 8-line spread"
is false for the 9-line layout (7 lines). The only robust rule is the one the DB
already gives: **render each page with the exact number of rows it has.**

## Approach: measure the ceiling, don't tune it

A Mushaf page has one uniform body font size, and exactly two things can
overflow: vertically (the N rows must fit the height) and horizontally (the
widest line must fit the width). The largest non-overflowing size is the minimum
of those two ceilings, derived from the actual page in the actual box — making it
**form-factor independent and overflow-proof by construction**, with no reference
width, no per-layout maximum, and no clamp.

`lib/utils/page_fit.dart` — `PageFit`:

- `bodyFontSize({verticalUnits, widestLineWidthAtProbe, box, probe})` — pure
  geometry. `verticalCeiling = box.height / verticalUnits`;
  `horizontalCeiling = probe × box.width / widestLineWidthAtProbe` (line width is
  linear in font size); returns `min(...)`. Falls back to the vertical ceiling
  when there are no body lines.
- `measureWidestLineWidth(lines, fontFamily, probe)` — one `TextPainter` pass
  over the body lines; the widest governs the horizontal ceiling.
- `forPage(page, box, fontFamily, rowUnits)` — composes the two, summing
  `rowUnits(line)` over the page's **actual** rows, so the 7/8-line opening
  spreads get larger glyphs for free.

**Vertical units, not line count.** Rows are not all the same height: an ornament
row (surah-name frame, basmallah) renders at a larger multiple of the body size
than a body row, so it is taller. The vertical ceiling therefore divides the
height by the *sum of each row's height multiple* (`verticalUnits`), not
`lineCount × leading`. A pure-body page has `verticalUnits == lineCount × leading`;
ornament-heavy pages (e.g. page 604 — the three closing surahs, three header
frames + three basmallahs on one 15-row page) have more, so the body shrinks just
enough to fit. The caller (`MushafPage._rowUnits`) owns the per-row multiple
because it knows the styling multipliers (`headerScaleFactor`,
`basmallahScaleFactor`, `ornamentLineHeight`); `PageFit` stays pure geometry. A
small `pageFitSafetyFactor` (1%) guards against sub-pixel overflow on exact-fit
pages.

`leading` / `ornamentLineHeight` (line-box-to-glyph ratios) are the remaining
tunables — but they are typographic properties of the script, **not** form-factor
values, so they stay.

## Phase 1 — what landed

- **`lib/utils/page_fit.dart`** — `PageFit` (new), unit-tested
  (`test/utils/page_fit_test.dart`, 11 cases: vertical/horizontal bound,
  probe-independence, ornament-weighting, empty page, asserts).
- **`mushaf_page.dart`** — wraps the line column in a `LayoutBuilder`, measures
  the body size once against the real post-padding box via `PageFit.forPage`
  (with a per-row `_rowUnits` mapping), applies `pageFitSafetyFactor`, and passes
  it down. A memo (`_fitKey`) avoids re-measuring on bookmark / memorization
  rebuilds (which don't change the grid or the box).
- **`constants.dart`** — adds `ornamentLineHeight` (shared by renderer + fit) and
  `pageFitSafetyFactor`.
- **`mushaf_line.dart`** — takes `bodyFontSize` as a parameter; the
  `min(w/428, h/926)` scale, the `clamp(16, 30)`, and the `fontSizeSettingProvider`
  read are gone. Ornament rows (surah name / basmallah) derive from the body size
  via the existing multipliers.

The page font is loaded (`await fontLoader.load()`) before `pageFontFamily` is
set on `PageData`, so the horizontal measurement uses real glyph metrics, not a
fallback.

**Visible effect:** on a reference phone the old clamped body size was `20`; the
new measured size fills the page (vertical ceiling ≈ 28 for a 15-line page).
Larger, page-filling text is the intended result.

**Verified on the iOS simulator** (iPhone 16 Pro, Uthmani 15-line): page 3 (dense
full page) fills top-to-bottom with no overflow; page 1 (8-line Al-Fatiha spread)
renders larger centered glyphs; page 604 (three closing surahs — the
ornament-heavy worst case) initially overflowed by 14px, which surfaced the
vertical-units bug above and is fixed by `_rowUnits`. The reading surface has no
golden coverage (604 page fonts aren't bundled for `loadAppFonts`), so this manual
pass is the visual regression check for now.

**Not in render anymore (but still defined — other surfaces use them):**
`referenceScreenWidth/Height`, `layoutMaxFontSizes`, `minAyahFontSize/maxAyahFontSize`.

## Justification — natural spacing, stretched to fill (landed)

The old renderer faked justification with `Row(MainAxisAlignment.spaceBetween)` +
manual space widgets, which dumped a vertical-bound page's horizontal slack into a
few inter-word gaps (the loose 9-line spacing). Flutter cannot justify a single
line (`TextAlign.justify` skips the last/only line) and the authored fonts' own
kashida justification is not reachable through Flutter text shaping, so:

`mushaf_line.dart` now lays each ayah line out at the font's **natural** spacing
(one space between words) and, for full lines, stretches it horizontally to the
column width with `FittedBox(BoxFit.fill)` over a fixed-height `SizedBox` — a
kashida-like widening spread evenly across the line (scaleX only; height
unchanged). Lines flagged `is_centered` stay centered at natural size (the print
convention for surah-ends). The dead `lineAlignment`/`justify` computation was
removed, and the per-word memorization `AnimatedSwitcher` now honors
`MediaQuery.disableAnimationsOf` (reduce-motion). **Verified on the simulator**:
the 9-line page is fully justified with natural spacing (no loose gaps, no ragged
edge); page 604 stays justified *and* fits.

## Derived constants (landed)

The `pageFitSafetyFactor = 0.99` blanket fudge is replaced by
`pageFitVerticalEpsilon = 1.0` — a one-logical-pixel rounding guard shaved off the
height in `PageFit` (`verticalSafetyPx`), an absolute epsilon rather than a
percentage. `layoutLineHeights` / `ornamentLineHeight` are documented as
intentional *typographic leading* (vertical-rhythm design values), not quantities
derivable from font ascent/descent.

## Phases still open

1. **Expanded-row grid** — replace `Column(center)` with weighted-`Flexible` rows
   (flex ∝ row units) so vertical fit is structural (no overflow possible, no
   epsilon) and short pages distribute vertically. The measured size already
   prevents overflow today; this is the deeper architectural form.
2. **Full adaptive chrome** — `WindowSizeClass` (Material 3 breakpoints) now
   exists in `utils/responsive.dart` as the foundation; the remaining work is a
   navigation rail / multi-pane chrome on `expanded`+ widths and unlocking the
   portrait lock (documented as deliberate in `main.dart`). `referenceScreen*`
   retire once `ResponsiveMetrics` moves onto size classes.
3. **Design-token completion** — `AppOpacity` (all 31 opacity literals migrated)
   and `AppDurations` (UI transitions + reduce-motion) are in; a full
   `ThemeExtension` spacing/radius set and the remaining domain-timing constants
   are the follow-up.
