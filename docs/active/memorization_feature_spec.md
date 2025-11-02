# Mushaf Memorization Beta Feature: Specification

_Version: 0.2 (Simplified Interaction Model)_

## 1. Overview & Goal

This document specifies the behavior of the page-based memorization feature, code-named "Chaining".

The primary goal is to aid users in memorizing entire pages of the Qur'an through a process of active recall and progressive revelation. The system presents a limited "window" of ayat, which gradually fade as the user recites them (signaled by a confirmation tap). This encourages the user to recall the current ayah from memory while simultaneously seeing the beginning of the next ayah, strengthening the link—or "chain"—between them.

## 2. Core User Experience (UX) Flow

### 2.1. Entering & Exiting Memorization Mode

**Activation**: The user can start a memorization session on the current page via a dedicated toggle button, likely located in the bottom action menu.

**Session State**: Once activated, the page enters "Memorization Mode". This state is persistent; if the user leaves the page and returns, the session will be automatically resumed.

**Deactivation**: The user can end the session at any time using the same toggle. Upon exit, the session progress is saved, and a confirmation toast ("Memorization progress saved") is displayed.

### 2.2. The Memorization Canvas

**Ayah Window**: Instead of seeing the full page, the user is shown a small, sliding window of active ayat (typically 1 to 3).

**Opacity as Progress**: Ayat within the window have varying opacities. A fully opaque ayah (1.0) is new, while a partially transparent or fully invisible ayah (0.0) is one the user has recited.

**Visual State**: All non-ayah UI elements (surah headers, basmallah) remain fully visible. Only the ayat themselves are subject to fading.

### 2.3. Primary Interaction: Advancing

**Recitation Signal**: The primary interaction is a single, persistent "Confirm Recitation" button (e.g., a ✓ icon). Tapping this button signifies one successful recitation of the currently focused ayah(s).

**Effect**: Each tap reduces the opacity of all visible ayat in the window by a fixed amount (the "fade step"). This interaction should provide clear visual feedback (e.g., a brief animation) to confirm the tap was registered.

### 2.4. Progression: Fading & Revealing

The core of the feature is an automated cycle of fading and revealing:

**User Confirms Recitation**: The user presses the confirmation button. Opacity of visible ayat decreases.

**Threshold Check**: When the oldest visible ayah fades past a certain threshold (e.g., 60% transparent), the system is eligible to reveal the next ayah on the page.

**Reveal**: The next ayah appears, fully opaque. The window now includes a new ayah to be chained.

**Window Slide**: When the oldest ayah becomes completely invisible (opacity 0.0), it is removed from the window, and the window "slides" forward.

This creates a continuous, dynamic flow where the user is always focused on a small, manageable set of ayat.

### 2.5. Completion & Resumption

**Page Completion**: A "pass" is complete when the user has successfully recited all ayat on the page, and the final ayah has faded completely from view.

**Resumption**: All session state (the exact ayat in the window, their opacities) is saved automatically on every interaction. When the user navigates back to a page with an in-progress session, the UI is restored to the exact state they left it in, heralded by a "Memorization session resumed" toast.

## 3. State Management & Logic

### 3.1. State Model (MemorizationSessionState)

The entire state for a given page's session is captured in an immutable model:

- `pageNumber`: The page this session belongs to.
- `window`: An `AyahWindowState` object containing:
  - `ayahIndices`: A `List<int>` of the zero-based indices of ayat currently visible on the page.
  - `opacities`: A `List<double>` of opacities (0.0 to 1.0), aligned with `ayahIndices`.
- `lastAyahIndexShown`: The index of the most recently revealed ayah.
- `lastUpdatedAt`: Timestamp of the last interaction.
- `passCount`: Number of times the user has completed the page.

### 3.2. Configuration (MemorizationConfig)

The logic is driven by a set of configurable parameters:

- `visibleWindowSize`: Maximum number of ayat in the window (e.g., `3`).
- `fadeStepPerTap`: The amount of opacity to reduce on each tap (e.g., `0.15`).
- `revealThresholdNext`: Opacity at which the next (n+1) ayah can be revealed (e.g., `<= 0.40`).
- `revealThresholdSecondNext`: Opacity at which a second-next (n+2) ayah can be revealed, for smoother chaining on long pages (e.g., `<= 0.70`).

### 3.3. Core Algorithms (MemorizationService)

The business logic is implemented as pure functions for predictability and testability.

- **`applyTap`**:
  - Reduces opacity for all ayat in the window by `fadeStepPerTap`.
  - Calls `_maybeRevealNext` to check if new ayat should be added.
  - Checks if the first ayah in the window has an opacity of `0.0`. If so, it removes it (slides the window).
  - Returns the new, updated `MemorizationSessionState`.

## 4. UI Components & Affordances

To make the feature understandable and usable, the following UI components are required:

- **Activation Control**: A toggle button/icon in `app_bottom_navigation.dart` or `mushaf_bottom_menu.dart`.
- **Session Indicator**: A chip or badge in `app_header.dart` that is visible only when a session is active on the current page. It should display "Memorization Mode".
- **Confirmation Button**: A floating action button (e.g., ✓) that is always visible during a session. This is the user's primary interaction point for signaling a successful recitation.
- **Feedback Toasts**: Non-intrusive snackbars for events like "Session saved" and "Session resumed".

## 5. Persistence (MemorizationStorage)

- **Interface**: An abstract `MemorizationStorage` class defines the contract for saving, loading, and clearing session state.
- **Implementation**: For the beta, an `InMemoryMemorizationStorage` is used. This can be swapped with a persistent implementation (e.g., SQLite, SharedPreferences) in the future without changing the business logic.
- **Behavior**: The state is saved after every single valid tap action, ensuring no progress is lost.

## 6. Edge Cases

- **Short Pages**: The logic naturally handles pages with fewer ayat than the `visibleWindowSize`. The window simply won't grow as large.
- **Single-Ayah Pages**: The feature works as expected. The user taps until the single ayah fades completely.
- **App Interruption**: Because state is persisted on every action, resuming the app will restore the session seamlessly.

## 7. Future Work & Open Questions

- Should `MemorizationConfig` settings be user-adjustable?
- Analytics: Track pass counts and time-per-page to provide user feedback.
- Cross-page chaining: Allow the session to flow seamlessly from the end of one page to the beginning of the next.
- Ayah Segmentation: For very long ayat, explore breaking them into smaller, recitable chunks.
- Self-Grading: Re-introduce a discoverable way for users to indicate difficulty (e.g., a "Forgot?" button separate from the main ✓ flow).
