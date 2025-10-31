# Bookmarks Feature Specification

**Version:** 1.0
**Date:** January 2025
**Status:** Ready for Implementation
**Priority:** High (Quarter 1)

---

## 1. Overview

### 1.1 Purpose

The Bookmarks feature allows users to save and quickly access their favorite pages in the Mushaf app. Bookmarks serve as personal collections of meaningful verses and pages, enabling users to return to specific content without navigation complexity.

### 1.2 Goals

- **Quick Access:** Enable users to bookmark any page with a single tap
- **Visual Organization:** Provide beautiful, intuitive interface for managing bookmarks
- **Persistence:** Save bookmarks locally with reliable storage
- **Seamless Integration:** Integrate naturally into existing app navigation
- **Performance:** Fast access and minimal overhead

### 1.3 Success Metrics

- Bookmark creation rate (target: 60% of active users create at least 1 bookmark)
- Bookmark usage rate (average bookmarks accessed per user)
- Time to access bookmarked page from bookmark screen
- User satisfaction with bookmark management

---

## 2. User Stories

### Primary Stories

1. **As a user**, I want to bookmark the current page while reading, so I can return to it later
2. **As a user**, I want to see all my bookmarked pages in one place, so I can quickly find what I'm looking for
3. **As a user**, I want to remove bookmarks I no longer need, so my list stays organized
4. **As a user**, I want to navigate directly to a bookmarked page, so I can continue reading from where I left off
5. **As a user**, I want to see context about each bookmark (surah name, page number, date), so I can identify it easily

### Secondary Stories

6. **As a user**, I want to see how many bookmarks I have, so I understand my collection size
7. **As a user**, I want to access bookmarks from multiple entry points (header, settings), so I can use them whenever convenient
8. **As a user**, I want bookmarks to persist across app sessions, so I don't lose my saved pages

---

## 3. Feature Requirements

### 3.1 Core Functionality

#### 3.1.1 Bookmark Creation

- **Trigger:** Tap bookmark icon in app header (when viewing Mushaf Screen)
- **Action:**
  - Toggle bookmark state (add if not bookmarked, remove if already bookmarked)
  - Show visual feedback (icon change, brief animation)
  - Save to persistent storage immediately
- **Behavior:**
  - If page already bookmarked: Remove bookmark (unbookmark)
  - If page not bookmarked: Add bookmark
  - Provide immediate visual feedback
- **Storage:** Save bookmark data to SQLite database

#### 3.1.2 Bookmark Display

- **List View:** Show all bookmarks in chronological order (newest first) or customizable order
- **Each Bookmark Shows:**
  - Page number (Arabic numerals: ١٥)
  - Surah name (if page contains surah start or main surah)
  - Juz number (glyph format: juz01, juz02, etc.)
  - Date bookmarked (relative: "Today", "Yesterday", "2 days ago", or absolute date)
  - Page preview thumbnail (optional, future enhancement)
- **Empty State:** Beautiful empty state message when no bookmarks exist

#### 3.1.3 Bookmark Navigation

- **Tap Bookmark:** Navigate directly to the bookmarked page
- **Close List:** Return to previous screen or close modal/drawer
- **Behavior:** Opening bookmark should preserve navigation stack (back button works correctly)

#### 3.1.4 Bookmark Removal

- **Method 1:** Tap bookmark icon again while on the bookmarked page (toggle off)
- **Method 2:** Swipe-to-delete in bookmark list
- **Method 3:** Long-press menu with delete option
- **Confirmation:** Optional (can be disabled in settings) - subtle snackbar "Bookmark removed"

#### 3.1.5 Bookmark Status Indication

- **In Header:** Bookmark icon shows filled/outlined state based on current page bookmark status
- **Visual Feedback:**
  - Outlined icon: Page not bookmarked
  - Filled icon: Page is bookmarked
  - Animation: Brief scale/fill animation when toggling

### 3.2 UI/UX Requirements

#### 3.2.1 Header Integration

**Location:** App header (existing header component)

**Icon Placement (RTL-aware):**

- Position: **Left side** of header in RTL layout (visual right side in LTR)
- Opposite from settings icon (which is on right side in RTL)
- Icon: `Icons.bookmark_border` (outlined) / `Icons.bookmark` (filled)
- Size: Match existing header icon size (`kAppHeaderIconSize = 24.0`)
- Color: Match existing header icon theme colors
- Tooltip: "حفظ الصفحة" / "Bookmark page" (RTL text direction)

**States:**

- **Not Bookmarked:** Outlined bookmark icon (default theme color)
- **Bookmarked:** Filled bookmark icon (primary theme color or accent)
- **Animations:**
  - On toggle: Scale animation (1.0 → 1.2 → 1.0) with color transition
  - Duration: 200ms
  - Easing: `Curves.easeInOut`

**Behavior:**

- Tap icon: Toggle bookmark status
- Show brief tooltip on first use (optional onboarding)
- Icon state updates immediately with animation

#### 3.2.2 Bookmarks Screen

**Access Points:**

1. New "Bookmarks" tab/item in Selection Screen bottom navigation (recommended)
2. OR: Dedicated screen accessible from Settings (alternative)
3. OR: Slide-up drawer/modal from header icon long-press (alternative)

**Recommended: Selection Screen Integration**

Add as fourth tab in Selection Screen (RTL layout):

- **Tab order (RTL - right to left visually):** **العلامات المرجعية** | السور | الأجزاء | الصفحات
- Tab label: "العلامات المرجعية" (Bookmarks) - primary, or "المحفوظات" (Saved) - alternative
- Icon: `Icons.bookmark` or `FlutterIslamicIcons.bookmark`
- **Note:** In RTL layout, tabs appear right-to-left, so Bookmarks (العلامات المرجعية) appears as the rightmost tab visually, first in logical order

**Screen Layout (RTL):**

```
┌─────────────────────────────────────────┐
│ [Header: Title + Bookmarks Icon]       │ ← Existing AppHeader component (RTL)
├─────────────────────────────────────────┤
│                                         │
│                        [Bookmark List]  │
│  ┌───────────────────────────────────┐ │
│  │                         الصفحة ١٥ 📖│ │
│  │                          البقرة    │ │
│  │   منذ يومين  juz01  محفوظة         │ │
│  ├───────────────────────────────────┤ │
│  │                       الصفحة ٣٤٧ 📖│ │
│  │                          آل عمران   │ │
│  │    أمس  juz04  محفوظة              │ │
│  ├───────────────────────────────────┤ │
│  │                       الصفحة ٤٠٣ 📖│ │
│  │                           النساء    │ │
│  │    اليوم  juz05  محفوظة             │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

**Empty State Design (RTL):**

```
┌─────────────────────────────────────────┐
│                                         │
│                         📑              │
│                                         │
│              لا توجد علامات مرجعية بعد  │
│                                         │
│  ابدأ القراءة واحفظ صفحاتك المفضلة    │
│  للوصول إليها بسرعة لاحقاً              │
│                                         │
│        [زر ابدأ القراءة]                │
│                                         │
└─────────────────────────────────────────┘
```

**List Item Design (RTL):**

- **Card Layout:**

  - Rounded corners (12px radius)
  - Padding: 16px horizontal, 12px vertical
  - Subtle shadow/elevation for depth
  - Tap ripple effect
  - Swipe-to-delete gesture (swipe **right** in RTL to reveal delete on left)
  - Text direction: `TextDirection.rtl` for Arabic content

- **Content (RTL Layout):**

  - **Right Side (Primary):** Page number with Eastern Arabic numerals (large, bold) with page icon
  - **Right Side (Secondary):** Surah name in Arabic (medium weight)
  - **Left Side (Tertiary):** Juz glyph + Date in Arabic (small, muted color)
  - **Left Side:** Chevron icon pointing left (←) for navigation indication (RTL-aware)

- **Typography:**

  - Page number: `fontSize: 20, fontWeight: w600`
  - Surah name: `fontSize: 16, fontWeight: w500`
  - Meta info: `fontSize: 14, color: muted`

- **Colors (Theme-Aware):**

  - Card background: `Theme.cardColor`
  - Text: `Theme.textTheme.bodyLarge?.color`
  - Muted text: `Theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6)`

- **Swipe Action (RTL-aware):**
  - Swipe **right** reveals red delete button (RTL direction)
  - Delete button appears on **left side** (RTL)
  - Delete button fills background: `Theme.colorScheme.error`
  - Delete icon: `Icons.delete_outline`
  - Smooth animation: 300ms
  - Use `Dismissible` widget with `direction: DismissDirection.endToStart` for RTL

#### 3.2.3 Navigation Flow

**Creating Bookmark (RTL Flow):**

```
Mushaf Screen (الصفحة ١٥)
  → Tap bookmark icon in header (left side in RTL)
  → Icon fills and animates
  → Snackbar: "تم حفظ الصفحة" / "Page bookmarked" (optional, can disable)
  → Bookmark saved to database
```

**Accessing Bookmarks (RTL Flow):**

```
Selection Screen
  → Tap "العلامات المرجعية" / "Bookmarks" tab
  → Bookmarks screen displays (RTL layout)
  → Tap bookmark item (right-aligned content)
  → Navigate to Mushaf Screen at bookmarked page
```

**Removing Bookmark (RTL Flow):**

```
Option A: From Mushaf Screen
  → Tap filled bookmark icon
  → Icon unfills and animates
  → Bookmark removed from database

Option B: From Bookmarks List (RTL Swipe)
  → Swipe bookmark item right (RTL direction)
  → Delete button appears on left side
  → Tap delete button
  → Item animates out
  → Bookmark removed from database
  → Snackbar: "تم حذف العلامة المرجعية" / "Bookmark removed"
```

---

## 4. Data Model

### 4.1 Bookmark Model

```dart
@immutable
class Bookmark {
  final int id; // Primary key (auto-increment)
  final int pageNumber; // The bookmarked page (1-604)
  final DateTime createdAt; // When bookmark was created
  final String? note; // Optional user note (future enhancement)

  const Bookmark({
    required this.id,
    required this.pageNumber,
    required this.createdAt,
    this.note,
  });

  Bookmark copyWith({
    int? id,
    int? pageNumber,
    DateTime? createdAt,
    String? note,
  }) {
    return Bookmark(
      id: id ?? this.id,
      pageNumber: pageNumber ?? this.pageNumber,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bookmark &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          pageNumber == other.pageNumber;

  @override
  int get hashCode => Object.hash(id, pageNumber);
}
```

### 4.2 Database Schema

**Table: `bookmarks`**

| Column        | Type    | Constraints               | Description         |
| ------------- | ------- | ------------------------- | ------------------- |
| `id`          | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique identifier   |
| `page_number` | INTEGER | NOT NULL UNIQUE           | Page number (1-604) |
| `created_at`  | TEXT    | NOT NULL                  | ISO 8601 timestamp  |
| `note`        | TEXT    | NULL                      | Optional user note  |

**Indexes:**

- `CREATE INDEX idx_bookmarks_page_number ON bookmarks(page_number);`
- `CREATE INDEX idx_bookmarks_created_at ON bookmarks(created_at DESC);`

**SQL Creation:**

```sql
CREATE TABLE IF NOT EXISTS bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  page_number INTEGER NOT NULL UNIQUE,
  created_at TEXT NOT NULL,
  note TEXT
);

CREATE INDEX IF NOT EXISTS idx_bookmarks_page_number
  ON bookmarks(page_number);

CREATE INDEX IF NOT EXISTS idx_bookmarks_created_at
  ON bookmarks(created_at DESC);
```

---

## 5. Service Layer

### 5.1 Bookmarks Service

**File:** `lib/services/bookmarks_service.dart`

**Responsibilities:**

- Database operations (CRUD)
- Bookmark existence checking
- List retrieval with ordering

**Interface:**

```dart
abstract class BookmarksService {
  Future<void> addBookmark(int pageNumber);
  Future<void> removeBookmark(int pageNumber);
  Future<bool> isBookmarked(int pageNumber);
  Future<List<Bookmark>> getAllBookmarks({bool newestFirst = true});
  Future<Bookmark?> getBookmarkByPage(int pageNumber);
  Future<void> clearAllBookmarks();
}
```

**Implementation Details:**

- Use SQLite database (existing `DatabaseService` pattern)
- Use `sqflite` package (already in project dependencies)
- Handle errors gracefully (catch exceptions, return empty lists)
- Use transactions for batch operations
- Implement caching for `isBookmarked()` checks (optional optimization)

### 5.2 Provider Integration

**File:** `lib/providers/bookmarks_provider.dart` (or add to `providers.dart`)

**Riverpod Providers:**

```dart
// Provider for bookmarks service
@riverpod
BookmarksService bookmarksService(Ref ref) {
  return SqliteBookmarksService();
}

// Provider for all bookmarks list
@riverpod
Future<List<Bookmark>> bookmarks(Ref ref) async {
  final service = ref.watch(bookmarksServiceProvider);
  return service.getAllBookmarks();
}

// Provider for checking if specific page is bookmarked
@riverpod
Future<bool> isPageBookmarked(Ref ref, int pageNumber) async {
  final service = ref.watch(bookmarksServiceProvider);
  return service.isBookmarked(pageNumber);
}

// Notifier for bookmark operations
@Riverpod(keepAlive: true)
class Bookmarks extends _$Bookmarks {
  @override
  Future<List<Bookmark>> build() async {
    final service = ref.read(bookmarksServiceProvider);
    return service.getAllBookmarks();
  }

  Future<void> toggleBookmark(int pageNumber) async {
    final service = ref.read(bookmarksServiceProvider);
    final isBookmarked = await service.isBookmarked(pageNumber);

    if (isBookmarked) {
      await service.removeBookmark(pageNumber);
    } else {
      await service.addBookmark(pageNumber);
    }

    // Invalidate to refresh list
    ref.invalidateSelf();
    ref.invalidate(isPageBookmarkedProvider(pageNumber));
  }

  Future<void> removeBookmark(int pageNumber) async {
    final service = ref.read(bookmarksServiceProvider);
    await service.removeBookmark(pageNumber);
    ref.invalidateSelf();
    ref.invalidate(isPageBookmarkedProvider(pageNumber));
  }
}
```

---

## 6. UI Components

### 6.1 Header Bookmark Icon

**Location:** `lib/widgets/shared/app_header.dart`

**Modifications:**

- Add optional `isBookmarked` parameter
- Add optional `onBookmarkPressed` callback
- Update icon based on `isBookmarked` state
- Add animation controller for toggle animation

**Usage in MushafScreen:**

```dart
AppHeader(
  title: title,
  trailing: BookmarkIconButton(
    pageNumber: currentPageNumber,
    onBookmarkChanged: () {
      // Refresh state if needed
    },
  ),
)
```

### 6.2 Bookmarks List Widget

**File:** `lib/widgets/bookmarks_list_view.dart`

**Features:**

- List of bookmark cards
- Swipe-to-delete gesture
- Empty state widget
- Loading state
- Error state handling

**Implementation:**

- Use `ListView.builder` for performance
- Implement `Dismissible` for swipe-to-delete
- Use Riverpod's `AsyncValue.when()` for state handling

### 6.3 Bookmark Item Card

**File:** `lib/widgets/bookmark_item_card.dart`

**Features:**

- Displays bookmark information
- Tap to navigate
- Swipe gesture support
- Theme-aware styling

---

## 7. Integration Points

### 7.1 Selection Screen

**File:** `lib/screens/selection_screen.dart`

**Changes Required:**

1. Add fourth tab: "Bookmarks"
2. Add `BookmarksListView` as fourth preloaded view
3. Update `selectionTabIndexProvider` range (0-3 instead of 0-2)
4. Update `_getScreenTitle()` to handle index 3

### 7.2 Mushaf Screen

**File:** `lib/screens/mushaf_screen.dart`

**Changes Required:**

1. Watch `isPageBookmarkedProvider(currentPageNumber)` to get bookmark status
2. Pass bookmark state to `AppHeader` via `trailing` parameter
3. Handle bookmark toggle in header callback
4. Invalidate bookmark providers after toggle

### 7.3 App Bottom Navigation

**File:** `lib/widgets/shared/app_bottom_navigation.dart`

**Changes Required:**

- Add fourth navigation item for "Bookmarks"
- Update `AppBottomNavigationType.selection` to support 4 items
- Update selection logic to handle index 3

---

## 8. Technical Implementation

### 8.1 Database Migration

**Approach:** Add bookmarks table creation to existing `DatabaseService` or create new initialization

**Location:** `lib/services/database_service.dart` or new migration file

**Version Management:**

- If using database versioning, increment version number
- Add migration script for existing users
- Create table on first app launch after update

### 8.2 State Management

- Use Riverpod (existing pattern)
- Providers for reactive state
- `AsyncValue` for loading/error states
- Invalidation on mutations

### 8.3 Performance Considerations

- **Lazy Loading:** Load bookmarks list on demand (when tab is opened)
- **Caching:** Cache `isBookmarked()` results per page (within same session)
- **Indexing:** Database indexes on `page_number` and `created_at`
- **Limit:** Consider pagination if bookmarks list grows very large (unlikely for typical use)

### 8.4 Error Handling

- **Database Errors:** Catch and log, show user-friendly message
- **Network Errors:** N/A (offline-first)
- **Validation:** Ensure page numbers are valid (1-604 range)
- **Empty States:** Graceful handling of no bookmarks

---

## 9. Edge Cases

### 9.1 Duplicate Bookmarks

- **Prevention:** UNIQUE constraint on `page_number` in database
- **Behavior:** If user tries to bookmark already-bookmarked page, toggle removes it
- **Error Handling:** Catch UNIQUE constraint violation gracefully

### 9.2 Invalid Page Numbers

- **Validation:** Ensure page numbers are between 1 and 604
- **Error Handling:** Show error message if invalid page attempted

### 9.3 Database Errors

- **Recovery:** Log error, show snackbar message
- **Fallback:** Show cached state if available
- **User Feedback:** "Unable to save bookmark. Please try again."

### 9.4 Empty Bookmarks List

- **Display:** Beautiful empty state with helpful message
- **Action:** Optional "Start Reading" button to navigate to Mushaf

### 9.5 Rapid Toggles

- **Debouncing:** Optional debounce on rapid taps (200ms)
- **Optimistic UI:** Update UI immediately, sync to DB in background
- **Conflict Resolution:** Last action wins

---

## 10. Acceptance Criteria

### Functional Criteria

✅ User can bookmark any page (1-604) by tapping header icon
✅ Bookmark icon shows correct state (filled/outlined)
✅ User can view all bookmarks in dedicated list
✅ User can navigate to bookmarked page from list
✅ User can remove bookmark via toggle or swipe-to-delete
✅ Bookmarks persist across app restarts
✅ Bookmark state updates immediately when toggled
✅ No duplicate bookmarks (same page)
✅ Empty state displays when no bookmarks exist

### UI/UX Criteria

✅ Bookmark icon animates smoothly on toggle
✅ List items have appropriate spacing and typography
✅ Swipe-to-delete works smoothly
✅ Colors and styles match app theme
✅ RTL layout works correctly
✅ Loading states are handled gracefully
✅ Error states show user-friendly messages

### Performance Criteria

✅ Bookmark operations complete in < 100ms
✅ List loads in < 200ms
✅ No UI lag during bookmark operations
✅ Database queries are optimized (indexed)

### Accessibility Criteria

✅ Bookmark icon has semantic label/tooltip
✅ List items are tappable with adequate size
✅ Screen reader support for bookmark states
✅ Keyboard navigation (if applicable)

---

## 11. Future Enhancements (Out of Scope)

These features are **not** included in v1.0 but may be added later:

- **Notes on Bookmarks:** Add personal notes to bookmarks
- **Bookmark Folders/Categories:** Organize bookmarks into groups
- **Bookmark Sorting:** Sort by date, page number, surah, etc.
- **Bookmark Sharing:** Share bookmark list with others
- **Page Preview Thumbnails:** Show page preview in bookmark list
- **Ayah-Level Bookmarks:** Bookmark specific verses (not just pages)
- **Bookmark Search:** Search bookmarks by surah name or notes
- **Bookmark Statistics:** Show bookmark usage analytics

---

## 12. Testing Requirements

### Unit Tests

- Test bookmark creation
- Test bookmark deletion
- Test duplicate prevention
- Test `isBookmarked()` function
- Test list ordering (newest first)

### Widget Tests

- Test bookmark icon toggle animation
- Test bookmark list rendering
- Test empty state display
- Test swipe-to-delete gesture
- Test navigation on tap

### Integration Tests

- Test full bookmark flow: create → view → navigate → delete
- Test persistence across app restarts
- Test state synchronization between screens
- Test error handling and recovery

---

## 13. Design Assets

### Icons

- Bookmark outline: `Icons.bookmark_border` (Material)
- Bookmark filled: `Icons.bookmark` (Material)
- Alternative: Custom Islamic-themed bookmark icon (if available)

### Colors

- Default icon: `Theme.iconTheme.color`
- Bookmarked icon: `Theme.colorScheme.primary`
- Delete action: `Theme.colorScheme.error`

### Animations

- Toggle animation: 200ms scale animation
- Swipe animation: 300ms slide animation
- List item animation: 250ms fade/slide

---

## 14. Dependencies

### Existing Dependencies (Already in Project)

- `flutter_riverpod` - State management
- `sqflite` - Database operations
- Material Design icons (built-in)

### No New Dependencies Required

All required packages are already available in the project.

---

## 15. Implementation Checklist

### Phase 1: Database & Service Layer

- [ ] Create `Bookmark` model class
- [ ] Create database schema and migration
- [ ] Implement `BookmarksService` interface
- [ ] Implement `SqliteBookmarksService`
- [ ] Add database initialization code
- [ ] Write unit tests for service layer

### Phase 2: State Management

- [ ] Create Riverpod providers for bookmarks
- [ ] Create `Bookmarks` notifier class
- [ ] Implement `isPageBookmarked` provider
- [ ] Write tests for providers

### Phase 3: UI Components

- [ ] Create `BookmarkIconButton` widget
- [ ] Create `BookmarksListView` widget
- [ ] Create `BookmarkItemCard` widget
- [ ] Create empty state widget
- [ ] Implement swipe-to-delete gesture
- [ ] Write widget tests

### Phase 4: Integration

- [ ] Integrate bookmark icon into `AppHeader`
- [ ] Add Bookmarks tab to Selection Screen
- [ ] Connect Mushaf Screen to bookmark state
- [ ] Update navigation flows
- [ ] Add onboarding/tooltip (optional)

### Phase 5: Polish & Testing

- [ ] Add animations and transitions
- [ ] Theme integration testing
- [ ] RTL layout testing
- [ ] Performance optimization
- [ ] Integration testing
- [ ] User acceptance testing

---

## 16. Notes for Developer

### Code Style

- Follow existing project patterns (functional programming, immutable models)
- Use `@immutable` for all data classes
- Follow existing naming conventions
- Match existing code organization structure

### Database Pattern

- Follow existing `DatabaseService` pattern if present
- Use the same database file/connection as other features
- Ensure migrations are handled correctly for existing users

### State Management

- Use Riverpod code generation (`@riverpod` annotations)
- Run `dart run build_runner build` after adding providers
- Follow existing provider patterns in `providers.dart`

### UI/UX

- Match existing app theme and styling
- Follow existing responsive patterns
- Ensure RTL support (text direction awareness)
- Use existing helper functions (e.g., `convertToEasternArabicNumerals`)

### Testing

- Write tests alongside implementation
- Follow existing test patterns
- Test edge cases and error scenarios

---

**End of Specification**
