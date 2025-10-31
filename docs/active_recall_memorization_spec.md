# Active Recall Memorization Feature Specification

**Version:** 1.0
**Date:** January 2025
**Status:** Ready for Implementation
**Priority:** High (Phase 1 of Incremental Roadmap)
**Replaces:** Fading Opacity Memorization System

---

## 1. Overview

### 1.1 Purpose

The Active Recall Memorization feature replaces the fading opacity system with a binary hide/reveal model that supports authentic memorization practice. This approach eliminates false completion signals and encourages active recall through text hiding and self-grading.

### 1.2 Goals

- **Remove False Completion Signals:** Eliminate fading opacity that implies "done" when user hasn't truly memorized
- **Active Recall:** Encourage users to recite from memory before checking
- **Honest Self-Assessment:** Enable self-grading of difficulty without implying mastery
- **Chaining Preservation:** Maintain ayah-to-ayah connection through visible context
- **Simplicity:** Binary states (hidden/visible) are clearer than gradual fading

### 1.3 Success Metrics

- User engagement with memorization feature increases
- Session length increases (users spend more time practicing)
- Return rate to memorization sessions increases
- User feedback: "More helpful" / "Less confusing"
- Reduction in false confidence issues

---

## 2. User Stories

### Primary Stories

1. **As a user**, I want text to be completely hidden during memorization, so I can test my actual recall
2. **As a user**, I want to reveal text to check my accuracy, so I know if I recalled correctly
3. **As a user**, I want to grade my difficulty, so the system can suggest appropriate review schedules
4. **As a user**, I want to see context ayat, so I can maintain chaining while memorizing
5. **As a user**, I want clear binary states, so I don't get confused about my progress

### Secondary Stories

6. **As a user**, I want to hide text manually, so I can control when to test myself
7. **As a user**, I want to see my previous mastery levels, so I know what needs more practice
8. **As a user**, I want the system to remember my self-grades, so I can track improvement

---

## 3. Feature Requirements

### 3.1 Core Functionality

#### 3.1.1 Text Hiding/Revealing

- **Trigger:** Automatic when entering memorization mode (text starts hidden)
- **State:** Binary - text is either completely hidden or completely visible
- **Default:** Text hidden when memorization mode starts
- **Visibility Control:**
  - Hide text: Automatic (on start) or manual (button)
  - Reveal text: Tap "Reveal" button to check accuracy
  - Re-hide: After grading, text hides again for next review

#### 3.1.2 Active Recall Flow

- **Step 1:** Text is hidden (current ayah)
- **Step 2:** User recites from memory
- **Step 3:** User taps "Reveal" → text becomes visible
- **Step 4:** User compares recitation with text
- **Step 5:** User grades difficulty (✅ Easy | ⚠️ Medium | ❌ Hard)
- **Step 6:** System moves to next ayah (text hidden)

#### 3.1.3 Self-Grading System

- **Three Difficulty Levels:**
  - ✅ **Easy:** Recited correctly without hesitation
  - ⚠️ **Medium:** Recited correctly but with hesitation or minor errors
  - ❌ **Hard:** Struggled significantly, many errors, or couldn't recall
- **Mastery Mapping:**
  - Easy → Mastery Level 3
  - Medium → Mastery Level 2
  - Hard → Mastery Level 1
- **Purpose:** Used for future review scheduling (Phase 3)

#### 3.1.4 Chaining Context

- **Previous Ayah:** Always visible (for chaining context)
- **Current Ayah:** Hidden during recall, visible when revealed
- **Next Ayah:** Always visible (for preview/chaining forward)
- **Window Size:** Typically 3 ayat visible at once (previous, current, next)
- **Visual Connection:** Maintains visual flow between ayat

### 3.2 UI/UX Requirements

#### 3.2.1 Visual States

**Hidden Text:**
- Current ayah text is completely hidden
- Placeholder: Blank space or subtle indicator (dotted line, gray placeholder)
- No opacity/fading - completely removed from view

**Visible Text:**
- Full text displayed normally
- Clear, readable font
- No special styling (appears as normal Quran text)

**Context Ayat (Previous/Next):**
- Always visible (not hidden)
- Normal appearance
- Clear visual separation from current ayah

#### 3.2.2 Interaction Controls

**Primary Actions:**
1. **"Reveal" Button** (or "Check" button)
   - Visible when text is hidden
   - Primary action button
   - Icon: 👁️ or ✓
   - Tapping reveals text

2. **Self-Grade Buttons** (appear after reveal)
   - ✅ **Easy** button
   - ⚠️ **Medium** button
   - ❌ **Hard** button
   - Tapping grades and moves to next ayah

3. **"Hide Again" Button** (optional)
   - Re-hides text for another attempt
   - Appears after reveal, before grading

**Navigation:**
- **Previous Ayah:** Button to go back
- **Next Ayah:** Auto-advance after grading, or manual button
- **Exit Mode:** Button to exit memorization mode

#### 3.2.3 Screen Layout

```
┌─────────────────────────────────────────┐
│ [Header: Memorization Mode]             │
├─────────────────────────────────────────┤
│                                         │
│  [Previous Ayah - Full Text Visible]    │
│  ✅ Easy (mastered 3 times)              │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │ [Current Ayah - HIDDEN]            │ │
│  │ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │ │
│  │ (or blank space)                  │ │
│  └───────────────────────────────────┘ │
│                                         │
│  [Next Ayah - Full Text Visible]       │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  [👁️ Reveal]  [⏭️ Skip]           │ │
│  └───────────────────────────────────┘ │
│                                         │
│  Progress: Ayah 5 of 15                 │
│  🔵 Learning (3) | 🟡 Needs Review (2)  │
│                                         │
└─────────────────────────────────────────┘
```

**After Reveal:**
```
┌─────────────────────────────────────────┐
│  [Current Ayah - FULL TEXT VISIBLE]     │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  ✅ Easy  ⚠️ Medium  ❌ Hard       │ │
│  └───────────────────────────────────┘ │
│                                         │
│  [Hide Again] [Next Ayah →]             │
└─────────────────────────────────────────┘
```

#### 3.2.4 Visual Feedback

**Transitions:**
- Hide → Reveal: Smooth fade-in animation (200-300ms)
- Reveal → Hide: Smooth fade-out animation
- Grading: Brief feedback animation (checkmark, color flash)

**Mastery Indicators:**
- 🔵 **Learning:** Ayah not yet reviewed or Hard grade
- 🟡 **Needs Review:** Medium grade (review more often)
- 🟢 **Solid:** Easy grade (mastery level 3)

**Progress Display:**
- Current position: "Ayah 5 of 15"
- Mastery summary: "3 Easy | 2 Medium | 1 Hard" (for current session)
- Visual progress bar (optional)

---

## 4. Data Model

### 4.1 Updated Memorization Models

**File:** `lib/memorization/models.dart`

#### 4.1.1 AyahWindowState (Modified)

```dart
@immutable
class AyahWindowState {
  final List<int> ayahIndices; // absolute indices within the page
  final List<bool> isHidden; // aligned boolean - true if hidden, false if visible
  final List<int> masteryLevel; // aligned mastery levels: 0 (not reviewed), 1 (hard), 2 (medium), 3 (easy)
  final List<int> reviewCount; // aligned count of how many times reviewed

  const AyahWindowState({
    required this.ayahIndices,
    required this.isHidden,
    required this.masteryLevel,
    required this.reviewCount,
  });

  AyahWindowState copyWith({
    List<int>? ayahIndices,
    List<bool>? isHidden,
    List<int>? masteryLevel,
    List<int>? reviewCount,
  }) {
    return AyahWindowState(
      ayahIndices: ayahIndices ?? this.ayahIndices,
      isHidden: isHidden ?? this.isHidden,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahWindowState &&
          runtimeType == other.runtimeType &&
          listEquals(ayahIndices, other.ayahIndices) &&
          listEquals(isHidden, other.isHidden) &&
          listEquals(masteryLevel, other.masteryLevel) &&
          listEquals(reviewCount, other.reviewCount);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(ayahIndices),
    Object.hashAll(isHidden),
    Object.hashAll(masteryLevel),
    Object.hashAll(reviewCount),
  );
}
```

**Changes from Current Model:**
- ❌ Remove: `List<double> opacities` (fading system)
- ❌ Remove: `List<int> tapsSinceReveal` (tap counting)
- ✅ Add: `List<bool> isHidden` (binary hide/show)
- ✅ Add: `List<int> masteryLevel` (self-graded difficulty)
- ✅ Add: `List<int> reviewCount` (track review frequency)

#### 4.1.2 MemorizationSessionState (Modified)

```dart
@immutable
class MemorizationSessionState {
  final int pageNumber;
  final AyahWindowState window;
  final int currentAyahIndex; // Currently focused ayah (for hide/reveal)
  final DateTime lastUpdatedAt;
  final int totalPasses; // Total times page has been reviewed (not "completed")

  const MemorizationSessionState({
    required this.pageNumber,
    required this.window,
    required this.currentAyahIndex,
    required this.lastUpdatedAt,
    required this.totalPasses,
  });

  MemorizationSessionState copyWith({
    int? pageNumber,
    AyahWindowState? window,
    int? currentAyahIndex,
    DateTime? lastUpdatedAt,
    int? totalPasses,
  }) {
    return MemorizationSessionState(
      pageNumber: pageNumber ?? this.pageNumber,
      window: window ?? this.window,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      totalPasses: totalPasses ?? this.totalPasses,
    );
  }

  // ... equality operators
}
```

**Changes from Current Model:**
- ❌ Remove: `lastAyahIndexShown` (not needed for hide/reveal)
- ✅ Add: `currentAyahIndex` (tracks focused ayah for hide/reveal)
- ✅ Rename: `passCount` → `totalPasses` (clearer language)

#### 4.1.3 MemorizationConfig (Modified)

```dart
@immutable
class MemorizationConfig {
  final int visibleWindowSize; // usually 3 (previous, current, next)
  final bool startWithTextHidden; // default: true
  final bool autoAdvanceAfterGrade; // default: true
  final int masteryLevels; // 3 levels (Easy=3, Medium=2, Hard=1)

  const MemorizationConfig({
    this.visibleWindowSize = 3,
    this.startWithTextHidden = true,
    this.autoAdvanceAfterGrade = true,
    this.masteryLevels = 3,
  });

  // ... copyWith and equality
}
```

**Changes from Current Model:**
- ❌ Remove: `fadeStepPerTap` (no fading)
- ❌ Remove: `tapsPerReveal` (no tap counting)
- ❌ Remove: `revealThresholdNext` (no threshold-based reveals)
- ❌ Remove: `revealThresholdSecondNext`
- ✅ Add: `startWithTextHidden` (configurable default)
- ✅ Add: `autoAdvanceAfterGrade` (move to next after grading)

---

## 5. Service Layer

### 5.1 Updated Memorization Service

**File:** `lib/services/memorization_service.dart`

**Changes Required:**

#### 5.1.1 Remove Fading Logic

```dart
// ❌ REMOVE THIS:
final fadedOpacities = state.window.opacities
    .map((o) => (o - fade).clamp(0.0, 1.0))
    .toList(growable: false);
```

#### 5.1.2 Add Hide/Reveal Logic

```dart
// ✅ NEW METHODS:

/// Reveals the current ayah text
MemorizationSessionState revealAyah({
  required MemorizationSessionState state,
  required int ayahIndex,
}) {
  final ayahPos = state.window.ayahIndices.indexOf(ayahIndex);
  if (ayahPos == -1) return state;

  final newIsHidden = List<bool>.from(state.window.isHidden);
  newIsHidden[ayahPos] = false; // Reveal

  return state.copyWith(
    window: state.window.copyWith(isHidden: newIsHidden),
  );
}

/// Hides the current ayah text
MemorizationSessionState hideAyah({
  required MemorizationSessionState state,
  required int ayahIndex,
}) {
  final ayahPos = state.window.ayahIndices.indexOf(ayahIndex);
  if (ayahPos == -1) return state;

  final newIsHidden = List<bool>.from(state.window.isHidden);
  newIsHidden[ayahPos] = true; // Hide

  return state.copyWith(
    window: state.window.copyWith(isHidden: newIsHidden),
  );
}

/// Grades the difficulty and moves to next ayah
MemorizationSessionState gradeAyah({
  required MemorizationSessionState state,
  required int ayahIndex,
  required int masteryLevel, // 1=Hard, 2=Medium, 3=Easy
  required int totalAyatOnPage,
}) {
  final ayahPos = state.window.ayahIndices.indexOf(ayahIndex);
  if (ayahPos == -1) return state;

  // Update mastery level and review count
  final newMasteryLevel = List<int>.from(state.window.masteryLevel);
  final newReviewCount = List<int>.from(state.window.reviewCount);

  newMasteryLevel[ayahPos] = masteryLevel;
  newReviewCount[ayahPos] = (newReviewCount[ayahPos] ?? 0) + 1;

  // Hide the ayah again (for future review)
  final newIsHidden = List<bool>.from(state.window.isHidden);
  newIsHidden[ayahPos] = true;

  // Move to next ayah
  int nextIndex = state.currentAyahIndex + 1;

  // Reveal next ayah if not in window
  final window = state.window;
  if (!window.ayahIndices.contains(nextIndex) && nextIndex < totalAyatOnPage) {
    // Add next ayah to window (hidden by default)
    final newIndices = [...window.ayahIndices, nextIndex];
    final newIsHiddenForNew = [...newIsHidden, true]; // Start hidden
    final newMasteryForNew = [...newMasteryLevel, 0]; // Not reviewed yet
    final newReviewForNew = [...newReviewCount, 0]; // No reviews yet

    return state.copyWith(
      window: AyahWindowState(
        ayahIndices: newIndices,
        isHidden: newIsHiddenForNew,
        masteryLevel: newMasteryForNew,
        reviewCount: newReviewForNew,
      ),
      currentAyahIndex: nextIndex,
      lastUpdatedAt: DateTime.now(),
    );
  }

  // If next ayah already in window, just update current index
  return state.copyWith(
    window: window.copyWith(
      isHidden: newIsHidden,
      masteryLevel: newMasteryLevel,
      reviewCount: newReviewCount,
    ),
    currentAyahIndex: nextIndex < totalAyatOnPage ? nextIndex : state.currentAyahIndex,
    lastUpdatedAt: DateTime.now(),
  );
}
```

#### 5.1.3 Start Session Logic

```dart
/// Starts a new memorization session
MemorizationSessionState startSession({
  required int pageNumber,
  required int firstAyahIndex,
  required MemorizationConfig config,
}) {
  return MemorizationSessionState(
    pageNumber: pageNumber,
    window: AyahWindowState(
      ayahIndices: [firstAyahIndex],
      isHidden: [config.startWithTextHidden], // Start hidden
      masteryLevel: [0], // Not reviewed
      reviewCount: [0], // No reviews
    ),
    currentAyahIndex: firstAyahIndex,
    lastUpdatedAt: DateTime.now(),
    totalPasses: 0,
  );
}
```

---

## 6. UI Components

### 6.1 Updated Memorization Widget

**File:** `lib/widgets/mushaf_page_widget.dart` (or separate memorization widget)

**Changes Required:**

#### 6.1.1 Text Rendering Logic

```dart
// For each ayah in window:
Widget buildAyah(int ayahIndex, bool isHidden) {
  if (isHidden) {
    // Show placeholder instead of text
    return Container(
      height: _calculateAyahHeight(ayahIndex),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          '━━━━━━━━━━━━━━━━━━━━',
          style: TextStyle(
            color: Colors.grey.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  // Show full text
  return _buildNormalAyahText(ayahIndex);
}
```

#### 6.1.2 Control Buttons

```dart
// When text is hidden:
if (isHidden) {
  return ElevatedButton.icon(
    onPressed: () {
      // Reveal text
      ref.read(memorizationSessionProvider.notifier).revealAyah(ayahIndex);
    },
    icon: Icon(Icons.visibility),
    label: Text('Reveal'),
  );
}

// When text is visible:
return Row(
  children: [
    ElevatedButton(
      onPressed: () => _gradeAyah(1), // Hard
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: Text('❌ Hard'),
    ),
    ElevatedButton(
      onPressed: () => _gradeAyah(2), // Medium
      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      child: Text('⚠️ Medium'),
    ),
    ElevatedButton(
      onPressed: () => _gradeAyah(3), // Easy
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      child: Text('✅ Easy'),
    ),
  ],
);
```

---

## 7. Integration Points

### 7.1 Memorization Provider

**File:** `lib/providers/memorization_provider.dart`

**Changes Required:**

```dart
class MemorizationSessionNotifier extends StateNotifier<MemorizationSessionState?> {
  // ... existing code ...

  /// Reveals the current ayah
  Future<void> revealAyah(int ayahIndex) async {
    if (state == null) return;

    final next = _service.revealAyah(
      state: state!,
      ayahIndex: ayahIndex,
    );

    state = next;
    await _maybePersist();
  }

  /// Hides the current ayah
  Future<void> hideAyah(int ayahIndex) async {
    if (state == null) return;

    final next = _service.hideAyah(
      state: state!,
      ayahIndex: ayahIndex,
    );

    state = next;
    await _maybePersist();
  }

  /// Grades an ayah and moves to next
  Future<void> gradeAyah({
    required int ayahIndex,
    required int masteryLevel, // 1=Hard, 2=Medium, 3=Easy
    required int totalAyatOnPage,
  }) async {
    if (state == null) return;

    final next = _service.gradeAyah(
      state: state!,
      ayahIndex: ayahIndex,
      masteryLevel: masteryLevel,
      totalAyatOnPage: totalAyatOnPage,
    );

    state = next;
    await _maybePersist();
  }

  // ❌ REMOVE: onTap method (replaced with reveal/grade)
}
```

---

## 8. Technical Implementation

### 8.1 Breaking Changes

**Migration Path:**
- Existing sessions in-memory will be lost (acceptable for beta)
- When implementing Phase 2 (Persistent Storage), ensure schema supports new model
- No database migration needed (Phase 2 will create new schema)

### 8.2 Testing Requirements

**Unit Tests:**
- Test reveal/hide logic
- Test grading and mastery level updates
- Test window management (adding new ayat)
- Test current ayah index tracking

**Widget Tests:**
- Test text hiding/display
- Test button states (reveal vs. grade buttons)
- Test transitions (hide → reveal → grade → next)

**Integration Tests:**
- Test full flow: start → hide → reveal → grade → next
- Test multiple ayat progression
- Test session resumption with new model

---

## 9. Edge Cases

### 9.1 Empty Page
- **Issue:** Page with no ayat
- **Solution:** Show message "No ayat to memorize on this page"

### 9.2 Single Ayah Page
- **Issue:** Only one ayah on page
- **Solution:** Still works, previous/next context may be from previous/next page (future)

### 9.3 Rapid Tapping
- **Issue:** User taps reveal/grade buttons rapidly
- **Solution:** Debounce button actions (200ms minimum between actions)

### 9.4 Window Size Management
- **Issue:** Window grows too large (many ayat revealed)
- **Solution:** Limit window size (config.visibleWindowSize), remove oldest when limit reached

---

## 10. Acceptance Criteria

### Functional Criteria

✅ Text is completely hidden (not faded) when memorization starts
✅ Text reveals when user taps "Reveal" button
✅ Self-grading buttons appear after reveal
✅ Mastery levels update correctly (1=Hard, 2=Medium, 3=Easy)
✅ System moves to next ayah after grading
✅ Previous/next ayat remain visible for chaining
✅ Window maintains 3 ayat (previous, current, next)
✅ Session state persists across app restarts (Phase 2)

### UI/UX Criteria

✅ Hidden text shows clear placeholder (not blank space)
✅ Reveal transition is smooth (200-300ms animation)
✅ Grade buttons are clearly labeled and color-coded
✅ Mastery indicators are visible (🔵🟡🟢)
✅ Progress display shows current position
✅ RTL layout works correctly
✅ Theme-aware styling

### Performance Criteria

✅ Hide/reveal actions complete in < 100ms
✅ No UI lag during transitions
✅ Smooth animations (60fps)
✅ Memory usage remains reasonable

---

## 11. Implementation Checklist

### Phase 1: Core Logic

- [ ] Update `AyahWindowState` model (remove opacity, add isHidden/masteryLevel)
- [ ] Update `MemorizationSessionState` model (add currentAyahIndex)
- [ ] Update `MemorizationConfig` (remove fade config, add hide config)
- [ ] Remove fading logic from `MemorizationService`
- [ ] Add `revealAyah()` method
- [ ] Add `hideAyah()` method
- [ ] Add `gradeAyah()` method
- [ ] Update `startSession()` to use hide/reveal
- [ ] Write unit tests for new logic

### Phase 2: UI Components

- [ ] Update ayah rendering to check `isHidden`
- [ ] Create placeholder widget for hidden text
- [ ] Create "Reveal" button
- [ ] Create grade buttons (Easy/Medium/Hard)
- [ ] Add mastery level indicators
- [ ] Add progress display
- [ ] Implement smooth transitions
- [ ] Update memorization provider methods
- [ ] Write widget tests

### Phase 3: Integration

- [ ] Update Mushaf Screen to use new buttons
- [ ] Remove old tap-to-fade interaction
- [ ] Test full user flow
- [ ] Update countdown circle (if still needed)
- [ ] Test RTL layout
- [ ] Test theme compatibility
- [ ] Performance testing
- [ ] Integration testing

### Phase 4: Polish

- [ ] Add animations for hide/reveal
- [ ] Add haptic feedback (optional)
- [ ] Improve visual design
- [ ] Add empty states
- [ ] Add error handling
- [ ] User acceptance testing

---

## 12. Notes for Developer

### Key Changes Summary

1. **Model Changes:**
   - Replace `opacities` (List<double>) with `isHidden` (List<bool>)
   - Remove `tapsSinceReveal` counter
   - Add `masteryLevel` tracking (1=Hard, 2=Medium, 3=Easy)
   - Add `reviewCount` tracking

2. **Service Changes:**
   - Remove `applyTap()` fading logic
   - Add `revealAyah()` method
   - Add `hideAyah()` method
   - Add `gradeAyah()` method

3. **UI Changes:**
   - Replace opacity-based text rendering with visibility toggle
   - Replace tap-to-fade with reveal/grade buttons
   - Add self-grading interface

### Breaking Changes

- Old sessions won't work (acceptable for beta)
- UI will need complete update for memorization mode
- Provider API changes (new methods, removed `onTap`)

### Future Compatibility

- This sets foundation for Phase 2 (Persistent Storage)
- Mastery levels will be used in Phase 3 (Spaced Repetition)
- Review count will be used for advanced AI features

---

**End of Specification**

