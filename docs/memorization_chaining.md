# Memorization Chaining (Page-Based) - MVP Spec

## Summary

- Whole-ayah, page-based acquisition with staggered chaining.
- Up to 3 visible ayat (optionally 4) with progressive fade.
- Anti-spam tap handling; resume exactly where user left off.

## Defaults

- Tap = one recitation cycle; ignore taps < 400ms apart.
- Visible window: 3 ayat (4 optional for long pages).
- Fade per valid tap: 0.15 (linear by default).
- Reveal thresholds:
  - Reveal ayah n+1 when ayah n opacity <= 0.40 (i.e., 60% faded)
  - Reveal ayah n+2 when ayah n opacity <= 0.70 AND ayah n+1 opacity <= 0.40
  - When oldest visible ayah opacity <= 0.00, remove it and slide window forward
- Boundary cross-check: permit next reveal only after at least one tap while both boundaries are visible (encourages chaining).

## User Actions

- Tap: counts as one recitation cycle; applies fade to eligible visible ayat.
- Self-grade (optional per step): Solid / Hesitant / Forgot
  - Solid: no change to flow
  - Hesitant: halve next fade step for current ayah once
  - Forgot: bump opacity of current ayah by +0.10 and block new reveals for the next tap

## State Model (per active page)

- pageNumber: int
- windowAyahIndices: List<int> (max length 3)
- windowOpacities: List<double> (0.0–1.0, aligned with indices)
- tapsSinceReveal: List<int> (aligned with indices)
- lastAyahIndexShown: int (absolute index within page)
- lastUpdatedAt: DateTime
- passCount: int (number of completed full passes on this page)

## Transitions (per valid tap)

1. Guard: ignore if <400ms since last tap (anti-spam).
2. Apply fade: reduce opacities for visible ayat by step (default 0.15), subject to any temporary adjustments (e.g., Hesitant).
3. Reveal checks:
   - If newest visible is ayah k and k+1 exists and oldest boundary requirement satisfied, reveal k+1 when thresholds are met.
   - If k+2 exists, apply the second-threshold rule.
4. Slide window:
   - If the oldest visible ayah reaches 0.0 opacity, remove it; shift window forward.
5. Completion:
   - When the last ayah of the page disappears and window slides past end, increment passCount and mark session complete for that page.

## Resume Behavior

- Persist state on each change (debounced ~300ms).
- On opening the same page, restore window and opacities exactly.

## Edge Cases

- Short pages (1–2 ayat): maintain logic with smaller window.
- Very long ayah: treated like any other (no segmentation in MVP).
- Late return: no rescheduling needed; resume where left off.

## Implementation Notes

- Keep state immutable; use Riverpod for updates.
- Store session state via a persistence interface (SQLite/Prefs) but start with in-memory; persistence can be plugged later.
- Use `withValues(alpha: x)` for fade visuals per project standards.
