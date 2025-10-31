# Memorization Feature - Incremental Development Roadmap

**Goal:** Build an AI-enhanced adaptive memorization system incrementally, starting simple and adding complexity.

**Philosophy:** Each phase should be valuable on its own and build on previous phases.

---

## Phase 1: Active Recall Memorization (Hide/Reveal Model)

**Feature Name:** Active Recall Memorization
**Spec Document:** `docs/active_recall_memorization_spec.md`
**Status:** Next Step
**Complexity:** Low
**Time Estimate:** 1-2 days
**Value:** Removes false completion signals, introduces active recall

### What Changes:

- ❌ Remove: Fading opacity system
- ✅ Add: Text hiding/revealing (binary: hidden or visible)
- ✅ Add: "Hide Text" button during memorization mode
- ✅ Add: "Reveal Text" to check after reciting
- ✅ Add: Self-grading buttons (✅ Easy | ⚠️ Medium | ❌ Hard)

### User Flow:

1. Start memorization mode
2. Text is hidden (not faded, completely hidden)
3. User recites from memory
4. Tap "Reveal" → text shows
5. Self-grade difficulty
6. Move to next ayah

### Implementation:

- Modify `MemorizationService` to use hide/reveal instead of opacity
- Replace `opacity` with `isHidden` boolean in `AyahWindowState`
- Update UI to show/hide text instead of fading
- Add self-grading buttons

### Why First:

- Simplest change (remove fading logic)
- Immediately better (no false completion)
- Sets foundation for future phases
- No new dependencies

---

## Phase 2: Persistent Storage

**Status:** After Phase 1
**Complexity:** Low-Medium
**Time Estimate:** 2-3 days
**Value:** Sessions persist across app restarts

### What Changes:

- ❌ Remove: `InMemoryMemorizationStorage`
- ✅ Add: `SqliteMemorizationStorage` (similar to bookmarks pattern)
- ✅ Add: Database table for memorization sessions
- ✅ Add: Session resume on app restart
- ✅ Add: Mastery state tracking (per ayah)

### Database Schema:

```sql
memorization_sessions:
  - id, page_number, ayah_index, is_hidden, last_reviewed, mastery_level
  - mastery_level: 0 (not reviewed), 1 (struggling), 2 (medium), 3 (easy)
```

### Why Second:

- Critical for real usage (sessions don't disappear)
- Uses existing pattern (bookmarks, reading progress)
- Enables future phases (need to track history)

---

## Phase 3: Simple Spaced Repetition (Fixed Intervals)

**Status:** After Phase 2
**Complexity:** Medium
**Time Estimate:** 3-4 days
**Value:** Suggests when to review based on mastery

### What Changes:

- ✅ Add: Review scheduling algorithm (fixed intervals)
  - Easy (mastery 3): Review in 3 days
  - Medium (mastery 2): Review tomorrow
  - Hard (mastery 1): Review in 4 hours
- ✅ Add: Review queue screen
- ✅ Add: "Due for Review" indicator on pages
- ✅ Add: Next review date display

### User Flow:

1. Grade ayah difficulty → mastery level saved
2. Algorithm calculates next review date
3. Review queue shows ayat due today
4. User reviews → updates mastery → new review date

### Why Third:

- Proven learning technique (spaced repetition)
- Builds on Phase 2 (needs mastery tracking)
- Still simple (fixed intervals, not AI yet)
- High value (suggests what to study)

---

## Phase 4: Audio Integration (Basic)

**Status:** After Phase 3
**Complexity:** Medium-High
**Time Estimate:** 1-2 weeks
**Value:** Audio-first approach (critical for hifz)

### What Changes:

- ✅ Add: Audio playback for ayat
- ✅ Add: Play/Pause button
- ✅ Add: Repeat mode (loop current ayah)
- ✅ Add: Play previous/next ayah
- ✅ Add: Audio syncs with current ayah being memorized

### Dependencies:

- Audio files or API integration
- Audio player package (`just_audio` or similar)

### User Flow:

1. Start memorization
2. Audio plays current ayah automatically
3. Text hidden, user listens
4. User recites from memory
5. Reveal text to check
6. Audio can replay if needed

### Why Fourth:

- Critical for authentic hifz practice
- Enables Phase 5 (voice recording)
- Foundation for future AI validation

---

## Phase 5: Voice Recording (Self-Comparison)

**Status:** After Phase 4
**Complexity:** High
**Time Estimate:** 1-2 weeks
**Value:** Users can record and compare their recitation

### What Changes:

- ✅ Add: Record button (records user's voice)
- ✅ Add: Playback user's recording
- ✅ Add: Side-by-side comparison (original vs. user)
- ✅ Add: Simple waveform visualization (optional)

### User Flow:

1. Listen to original audio
2. Text hidden
3. User records their recitation
4. Play both: original → user's
5. Self-assess accuracy
6. Grade difficulty

### Why Fifth:

- Audio-focused validation (no AI needed yet)
- Users can hear their mistakes
- Prepares for AI validation (Phase 7)

---

## Phase 6: Adaptive Spaced Repetition (Basic AI)

**Status:** After Phase 5
**Complexity:** High
**Time Estimate:** 1-2 weeks
**Value:** Spacing adapts to your performance

### What Changes:

- ❌ Remove: Fixed intervals (from Phase 3)
- ✅ Add: Performance tracking (response time, hesitation, errors)
- ✅ Add: Adaptive algorithm (adjusts intervals based on performance)
- ✅ Add: Performance history per ayah
- ✅ Add: Predictive "forgetting curve" model

### Algorithm Logic:

```
If user always gets it right quickly → increase interval
If user struggles → decrease interval
Track actual retention (did they remember at review?)
Adjust future intervals based on retention rate
```

### Why Sixth:

- Makes spaced repetition smarter
- Builds on Phase 3 (spaced repetition)
- Uses data from Phase 5 (performance tracking)
- Still local AI (no external services)

---

## Phase 7: AI Voice Validation (Speech Recognition)

**Status:** After Phase 6
**Complexity:** Very High
**Time Estimate:** 2-4 weeks
**Value:** Real-time feedback on recitation accuracy

### What Changes:

- ✅ Add: Speech-to-text (Arabic recognition)
- ✅ Add: Word-level accuracy detection
- ✅ Add: Visual feedback (✅ correct | ❌ wrong word)
- ✅ Add: Accuracy percentage display
- ✅ Add: Hesitation detection (audio analysis)

### Dependencies:

- Speech recognition API or package
- Arabic language model

### User Flow:

1. User records recitation
2. AI transcribes (speech-to-text)
3. Compare with reference text
4. Show word-level errors
5. Display accuracy score
6. Combined with self-grading

### Why Seventh:

- Adds real AI validation
- Builds on Phase 5 (recording)
- Provides objective feedback
- Still self-contained (doesn't replace teacher)

---

## Phase 8: Advanced AI Features

**Status:** Future
**Complexity:** Very High
**Time Estimate:** 4+ weeks
**Value:** Predictive modeling, advanced adaptation

### What Changes:

- ✅ Add: Predictive performance modeling
- ✅ Add: Difficulty prediction ("You'll struggle with this")
- ✅ Add: Personalized chunk sizes
- ✅ Add: Advanced tajweed detection (if feasible)
- ✅ Add: Cross-user pattern learning (anonymized)

### Why Last:

- Most complex features
- Requires all previous phases
- May need external AI services
- Nice-to-have enhancements

---

## Summary Table

| Phase | Feature                 | Complexity | Time      | Dependencies                     |
| ----- | ----------------------- | ---------- | --------- | -------------------------------- |
| 1     | Hide/Reveal             | Low        | 1-2 days  | None                             |
| 2     | Persistent Storage      | Low-Med    | 2-3 days  | None (follows bookmarks pattern) |
| 3     | Fixed Spaced Repetition | Medium     | 3-4 days  | Phase 2                          |
| 4     | Audio Integration       | Med-High   | 1-2 weeks | Audio files/API                  |
| 5     | Voice Recording         | High       | 1-2 weeks | Phase 4                          |
| 6     | Adaptive Spacing        | High       | 1-2 weeks | Phase 3, 5                       |
| 7     | AI Voice Validation     | Very High  | 2-4 weeks | Phase 5, Speech API              |
| 8     | Advanced AI             | Very High  | 4+ weeks  | All previous                     |

---

## Implementation Priority

**Immediate (Next Sprint):**

- Phase 1: Hide/Reveal (MVP improvement)

**Short-term (Next Month):**

- Phase 2: Persistent Storage
- Phase 3: Fixed Spaced Repetition

**Medium-term (2-3 Months):**

- Phase 4: Audio Integration
- Phase 5: Voice Recording

**Long-term (6+ Months):**

- Phase 6: Adaptive Spacing
- Phase 7: AI Voice Validation
- Phase 8: Advanced AI

---

## Notes

- Each phase should be independently valuable
- Can pause development after any phase
- Phases build on each other logically
- Can test each phase before moving to next
- User feedback should guide prioritization

**Start with Phase 1** - it's the simplest improvement that removes the biggest problem (fading = false completion).
