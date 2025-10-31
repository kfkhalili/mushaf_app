# Bookmarks Feature Specification

**Version:** 4.0 (Long-Press Ayah Bookmarking)
**Date:** January 2025
**Status:** 📋 Ready for Implementation
**Priority:** High (Quarter 1)

**Note:** This specification reflects the **ayah-based bookmarking** approach with **long-press interaction** for precise, intentional bookmark creation. Bookmarks are stored at the ayah-level (surah:ayah) for universal, layout-independent bookmarks.

---

## 1. Overview

### 1.1 Purpose

The Bookmarks feature allows users to save and quickly access their favorite verses (ayat) in the Mushaf app. **Bookmarks are stored at the ayah-level (surah:ayah)**, ensuring they work perfectly across all Mushaf layouts (Uthmani, Indopak, etc.). This approach provides universal bookmarks that always navigate to the same content regardless of layout differences.

### 1.2 Goals

- **Universal Bookmarks:** Store bookmarks at ayah-level (surah:ayah) for perfect cross-layout compatibility
- **Precise Interaction:** Enable users to bookmark specific ayat through long-press gesture on the text
- **Intentional Bookmarking:** Require explicit user action (long-press) to ensure purposeful bookmark creation
- **Visual Feedback:** Highlight selected ayah and provide clear confirmation when bookmarked
- **Precise Navigation:** Navigate to exact verse content, regardless of layout or page number differences
- **Visual Organization:** Provide beautiful, intuitive interface showing verse references (e.g., "٢:٢٥٥")
- **Persistence:** Save bookmarks locally with reliable storage and migration from page-based bookmarks
- **Seamless Integration:** Integrate naturally into existing app navigation without interfering with reading flow
- **Performance:** Fast access and minimal overhead

### 1.3 Success Metrics

- Bookmark creation rate (target: 60% of active users create at least 1 bookmark)
- Bookmark usage rate (average bookmarks accessed per user)
- Time to access bookmarked page from bookmark screen
- User satisfaction with bookmark management

---

## 2. User Stories

### Primary Stories

1. **As a user**, I want to long-press on a specific ayah to bookmark it, so I can save the exact verse I'm interested in
2. **As a user**, I want to see the ayah I'm bookmarking highlighted, so I can confirm I selected the correct verse
3. **As a user**, I want to see all my bookmarked verses in one place, so I can quickly find what I'm looking for
4. **As a user**, I want to remove bookmarks I no longer need, so my list stays organized
5. **As a user**, I want to navigate directly to a bookmarked verse, so I can continue reading from the exact same content (works across all layouts)
6. **As a user**, I want to see context about each bookmark (verse reference like "٢:٢٥٥", surah name, page number in current layout, date), so I can identify it easily

### Secondary Stories

7. **As a user**, I want to see how many bookmarks I have, so I understand my collection size
8. **As a user**, I want to access bookmarks from the Selection Screen header, so I can view my saved verses easily
9. **As a user**, I want bookmarks to persist across app sessions, so I don't lose my saved verses
10. **As a user**, I want clear visual feedback when I bookmark an ayah, so I know the action succeeded

---

## 3. Feature Requirements

### 3.1 Core Functionality

#### 3.1.1 Bookmark Creation (Long-Press on Ayah)

- **Trigger:** User long-presses on any ayah text in Mushaf Screen
- **Long-Press Duration:** 400-500ms (standard Flutter gesture)
- **Action Flow:**

  1. Detect long-press gesture on ayah text
  2. Identify which ayah was pressed (ayah boundary detection)
  3. Highlight the selected ayah (visual feedback)
  4. Show context menu with "Bookmark" option
  5. User taps "Bookmark" in menu
  6. Save ayah reference (surah:ayah) to persistent storage
  7. Show confirmation feedback (snackbar or brief animation)
  8. Remove highlight after confirmation

- **Ayah Detection:**

  - Detect which ayah contains the tap coordinates
  - Use page layout data to determine ayah boundaries
  - Handle edge cases (tap between ayat, partial ayah visibility)
  - If ambiguous, use the ayah whose center is closest to tap point

- **Visual Feedback:**

  - **Highlight:** Selected ayah highlighted with subtle background color (primary color at 15-20% opacity)
  - **Context Menu:** Appears near tap location (or centered if space constrained)
  - **Menu Options:**
    - "Bookmark" (primary action) - Bookmark icon + text
    - Future: "Share", "Copy", "Notes" (out of scope for v1)
  - **Confirmation:** Brief snackbar: "تم حفظ الآية" / "Ayah bookmarked" (1.5-2 seconds)

- **Behavior:**

  - Bookmark is stored as surah:ayah pair (e.g., 2:255), not page number
  - If same ayah already bookmarked: Toggle off (unbookmark) - show "Remove bookmark" option
  - If ayah not bookmarked: Add bookmark
  - Highlight and menu dismissed automatically after bookmarking or tapping elsewhere

- **Storage:** Save ayah reference (surah_number, ayah_number) to SQLite database immediately

- **Edge Cases:**
  - **Tap between ayat:** Select the ayah whose center is closest to tap point
  - **Partial ayah visibility:** Select the visible portion's ayah
  - **Long-press during swipe:** Ignore if swipe is in progress (prevent accidental bookmarks)
  - **Multiple ayat selected:** Only bookmark the ayah containing the tap point
  - **No ayah detected:** Show error: "لم يتم العثور على آية" / "Ayah not found"

#### 3.1.2 Bookmark Display

- **List View:** Show all bookmarks in chronological order (newest first) or customizable order
- **Each Bookmark Shows:**
  - **Verse reference** (ayah reference: "٢:٢٥٥" - Surah 2, Ayah 255) - **Primary identifier**
  - **Page number** (Arabic numerals: "الصفحة ٣٠٢") - Secondary, dynamically shown for current layout
  - Surah name glyph (if available)
  - Date bookmarked (relative: "Today", "Yesterday", "2 days ago", or absolute date)
  - Page preview thumbnail (optional, future enhancement)
- **Display Format:**
  - Primary: Verse reference (e.g., "٢:٢٥٥")
  - Optional: Page number in parentheses (e.g., "٢:٢٥٥ (الصفحة ٣٠٢)")
  - Page number updates dynamically based on current layout (different layouts may show different page numbers)
- **Empty State:** Beautiful empty state message when no bookmarks exist

#### 3.1.3 Bookmark Navigation

- **Tap Bookmark:** Navigate to the page containing the bookmarked ayah in the current layout
- **Navigation Logic:**
  1. Get bookmark: (surahNumber, ayahNumber)
  2. Call: `getPageForAyah(surahNumber, ayahNumber)` to find page in current layout
  3. Navigate to returned page number
- **Benefits:**
  - Always navigates to correct content (same ayah, any layout)
  - No mapping calculation needed
  - Works seamlessly across layout switches
- **Close List:** Return to previous screen or close modal/drawer
- **Behavior:** Opening bookmark should preserve navigation stack (back button works correctly)

#### 3.1.4 Bookmark Removal

- **Method 1:** Long-press on already-bookmarked ayah → Context menu shows "Remove bookmark" → Tap to unbookmark
- **Method 2:** Swipe-to-delete in bookmark list (RTL swipe right to reveal delete)
- **Method 3:** Long-press menu on bookmark item in list → Delete option
- **Confirmation:** Subtle snackbar "تم حذف العلامة المرجعية" / "Bookmark removed" (1.5-2 seconds)

#### 3.1.5 Bookmark Status Indication

- **Visual Indicator on Ayah:** When viewing a page, ayat that are already bookmarked should show a subtle visual indicator
  - **Option 1 (Recommended):** Small bookmark icon in corner of bookmarked ayah
  - **Option 2:** Subtle colored border or background tint on bookmarked ayat
  - **Option 3:** Only show indicator on hover/long-press (minimal visual clutter)
- **Context Menu State:** When long-pressing a bookmarked ayah, menu shows "Remove bookmark" instead of "Bookmark"
- **List View:** Bookmarks list shows all bookmarked ayat with clear visual distinction

### 3.2 UI/UX Requirements

#### 3.2.1 Header Integration

**Location:** App header (existing header component)

**Two Contexts for Bookmark Icon:**

1. **Mushaf Screen (Current Page Bookmark):**

   - Position: **Left side** of header in RTL layout (with Settings/Search icons)
   - Icon state: Outlined (not bookmarked) / Filled (bookmarked)
   - Color: Outlined = default grey, Filled = primary color
   - Behavior: Toggles bookmark for current page
   - Only visible on Mushaf Screen

2. **Selection Screen (Bookmarks Access):**
   - Position: **Left side** of header in RTL layout (with Settings/Search icons)
   - Icon: Always **filled** (`Icons.bookmark`)
   - Color: **Grey** to match Settings and Search icons (`Colors.grey.shade400` dark / `Colors.grey.shade600` light)
   - Size: Match existing header icon size (`kAppHeaderIconSize = 24.0`)
   - Behavior: Tap icon to navigate to Bookmarks screen/list
   - Always visible on Selection Screen

**Icon Placement (RTL-aware):**

- **Mushaf Screen:**

  - Position: **Left side** of header in RTL layout (same row as Settings and Search)
  - Order: Settings | Search | **Bookmarks** (from left to right in RTL visual layout)
  - Icon appears with Settings/Search icons

- **Selection Screen:**

  - Position: **Right side** of header in RTL layout (opposite from Settings/Search)
  - Separated from Settings and Search icons (on different side of header)
  - Appears on the **trailing** side (right side in RTL, visually left side)

- Size: Match existing header icon size (`kAppHeaderIconSize = 24.0`)
- Color:
  - Mushaf Screen: Dynamic (outlined grey / filled primary)
  - Selection Screen: Always filled grey (`Colors.grey.shade400` dark / `Colors.grey.shade600` light)
- Tooltip: "العلامات المرجعية" / "Bookmarks" (RTL text direction)

**States:**

- **Mushaf Screen:**
  - Not Bookmarked: Outlined bookmark icon (default grey color)
  - Bookmarked: Filled bookmark icon (primary theme color)
- **Selection Screen:**
  - Always: Filled bookmark icon (grey color, matches Settings/Search)
- **Animations:**
  - On toggle (Mushaf): Scale animation (1.0 → 1.2 → 1.0) with color transition
  - Duration: 200ms
  - Easing: `Curves.easeInOut`

**Behavior:**

- **Mushaf Screen:** Tap icon to toggle bookmark status for current page
- **Selection Screen:** Tap icon to navigate to Bookmarks screen/list
- Icon state updates immediately with animation (Mushaf only)

#### 3.2.3 Bookmarks Screen

**Access Point:**

- **Primary:** Tap bookmark icon in Selection Screen header (always visible, filled grey icon)
- Opens dedicated Bookmarks screen (full screen, replaces Selection Screen content)

**Navigation Pattern:**

- Selection Screen → Tap header bookmark icon → Bookmarks Screen
- Bookmarks Screen has back button to return to Selection Screen
- Bookmarks Screen shows empty title in header (or "العلامات المرجعية")

**Screen Layout (RTL - Improved Design):**

```
┌─────────────────────────────────────────┐
│ [Header: Empty Title + Back + Icons]    │ ← Existing AppHeader component (RTL)
├─────────────────────────────────────────┤
│                                         │
│         [Bookmark List - RTL Layout]   │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  ←                         ١٥ 📖   ││  ← Arrow LEFT, content RIGHT
│  │                               البقرة ││  ← Right-aligned text
│  │                    منذ يومين • juz01 ││  ← Right-aligned text
│  ├─────────────────────────────────────┤│
│  │  ←                       ٣٤٧ 📖   ││
│  │                            آل عمران ││
│  │                        أمس • juz04 ││
│  ├─────────────────────────────────────┤│
│  │  ←                       ٤٠٣ 📖   ││
│  │                              النساء ││
│  │                        اليوم • juz05││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

**Improved RTL Card Layout:**

- **Right-aligned content (RTL):**

  - Bookmark icon (📖) at right edge
  - Page number (الصفحة ١٥) immediately left of icon
  - Surah name (البقرة) below page number, left-aligned within card
  - Metadata (date • juz) below surah, smaller text

- **Left side:**

  - Chevron icon (←) pointing left for RTL navigation indication
  - Subtle, light grey color

- **Card spacing:**
  - More generous padding: 16px all around
  - Better visual hierarchy with clear grouping
  - Consistent spacing between elements

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

**List Item Design (RTL - Refined):**

- **Card Layout:**

  - Rounded corners (16px radius for softer look)
  - Padding: 16px all around (generous spacing)
  - Subtle shadow/elevation (2px elevation)
  - Tap ripple effect
  - Swipe-to-delete gesture (swipe **right** in RTL to reveal delete on left)
  - Text direction: `TextDirection.rtl` for all Arabic content
  - Card margin: 8px vertical between cards, 16px horizontal padding

- **Content Layout (RTL - Visual Hierarchy):**

```
┌─────────────────────────────────────────┐
│  ←                              📖 ١٥    │ ← Arrow on left, content on right
│                                     البقرة│ ← Right-aligned: Surah
│                        منذ يومين • juz01│ ← Right-aligned: Meta
└─────────────────────────────────────────┘
```

- **Right Side (Primary Content - MUST be right-aligned):**

  - Bookmark icon (📖) + Page number (الصفحة ١٥) on same line
  - Icon: 20px size, positioned at **right edge** with 4px spacing from page number
  - Page number: Large, bold, Eastern Arabic numerals
  - Surah name: Below page number, medium weight
  - Metadata: Below surah, small muted text (date • juz)
  - **ALL TEXT MUST BE RIGHT-ALIGNED** - Use `CrossAxisAlignment.end` in Column
  - Use `TextAlign.right` for all Text widgets
  - Content Column should use `crossAxisAlignment: CrossAxisAlignment.end`

- **Left Side (Navigation - Fixed position):**

  - Chevron icon (←) pointing **left** (RTL direction)
  - Position: Fixed on **left edge** of card
  - Light grey color, subtle
  - 24px size, centered vertically
  - Indicates tap to navigate (RTL direction - left is "forward")

- **Typography:**

  - Page number: `fontSize: 22, fontWeight: w700` (larger, bolder)
  - Bookmark icon: `fontSize: 20` (slightly smaller than page number)
  - Surah name: `fontSize: 16, fontWeight: w500`
  - Meta info: `fontSize: 13, fontWeight: w400, color: muted`
  - Line height: `1.4` for better readability

- **Colors (Theme-Aware):**

  - Card background: `Theme.cardColor`
  - Card border: Subtle border (`Theme.dividerColor.withValues(alpha: 0.3)`)
  - Primary text: `Theme.textTheme.bodyLarge?.color`
  - Secondary text: `Theme.textTheme.bodyMedium?.color`
  - Muted text: `Theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6)`
  - Chevron icon: `Theme.iconTheme.color?.withValues(alpha: 0.5)`
  - Bookmark icon: Match page number color

- **Visual Improvements:**

  - Clear visual hierarchy: Page number stands out most
  - Better spacing: More breathing room between elements
  - Consistent alignment: All Arabic text right-aligned
  - Subtle dividers: Thin border between cards (optional)
  - Icon positioning: Bookmark icon inline with page number for compact design

- **Swipe Action (RTL-aware):**
  - Swipe **right** reveals red delete button (RTL direction)
  - Delete button appears on **left side** (RTL)
  - Delete button fills background: `Theme.colorScheme.error`
  - Delete icon: `Icons.delete_outline`
  - Smooth animation: 300ms
  - Use `Dismissible` widget with `direction: DismissDirection.endToStart` for RTL

#### 3.2.4 Navigation Flow

**Creating Bookmark (Long-Press Flow):**

```
Mushaf Screen - User reading Quran
  → User long-presses on specific ayah (400-500ms)
  → Ayah highlights (visual feedback)
  → Context menu appears near tap location
  → User taps "Bookmark" / "حفظ" option
  → Ayah bookmarked (surah:ayah saved to database)
  → Snackbar: "تم حفظ الآية" / "Ayah bookmarked"
  → Highlight and menu dismissed
```

**Accessing Bookmarks (RTL Flow):**

```
Selection Screen
  → Tap filled grey bookmark icon in header (right side, separated from Settings/Search)
  → Navigate to Bookmarks Screen (full screen)
  → Tap bookmark item (right-aligned content)
  → Navigate to Mushaf Screen at bookmarked ayah's page
```

**Removing Bookmark (RTL Flow):**

```
Option A: From Mushaf Screen (Long-Press on Bookmarked Ayah)
  → User long-presses on already-bookmarked ayah
  → Ayah highlights, context menu appears
  → Menu shows "Remove bookmark" / "إزالة العلامة المرجعية"
  → User taps "Remove bookmark"
  → Bookmark removed from database
  → Snackbar: "تم حذف العلامة المرجعية" / "Bookmark removed"
  → Highlight and menu dismissed

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

**Updated for Ayah-Based Storage:**

```dart
@immutable
class Bookmark {
  final int id; // Primary key (auto-increment)
  final int surahNumber;  // ✅ Universal - Surah number (1-114)
  final int ayahNumber;   // ✅ Universal - Ayah number within surah
  final int? cachedPageNumber; // Optional: current layout's page (for performance, invalidated on layout change)
  final DateTime createdAt; // When bookmark was created
  final String? note; // Optional user note (future enhancement)

  const Bookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    this.cachedPageNumber,
    required this.createdAt,
    this.note,
  });

  Bookmark copyWith({
    int? id,
    int? surahNumber,
    int? ayahNumber,
    int? cachedPageNumber,
    DateTime? createdAt,
    String? note,
  }) {
    return Bookmark(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      cachedPageNumber: cachedPageNumber ?? this.cachedPageNumber,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  // Get formatted verse reference (e.g., "٢:٢٥٥")
  String get verseReference => '$surahNumber:$ayahNumber';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bookmark &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode => Object.hash(id, surahNumber, ayahNumber);
}
```

**Key Changes:**

- ❌ Removed: `pageNumber` (layout-dependent)
- ✅ Added: `surahNumber` + `ayahNumber` (universal)
- ✅ Added: Optional `cachedPageNumber` (performance optimization)
- ✅ Added: `verseReference` getter for display formatting

### 4.2 Database Schema

**Table: `bookmarks` (Updated for Ayah-Based)**

| Column               | Type    | Constraints               | Description                     |
| -------------------- | ------- | ------------------------- | ------------------------------- |
| `id`                 | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique identifier               |
| `surah_number`       | INTEGER | NOT NULL                  | Surah number (1-114)            |
| `ayah_number`        | INTEGER | NOT NULL                  | Ayah number within surah        |
| `cached_page_number` | INTEGER | NULL                      | Optional: current layout's page |
| `created_at`         | TEXT    | NOT NULL                  | ISO 8601 timestamp              |
| `note`               | TEXT    | NULL                      | Optional user note              |

**Constraints:**

- `UNIQUE(surah_number, ayah_number)` - One bookmark per ayah (prevent duplicates)

**Indexes:**

- `CREATE INDEX idx_bookmarks_surah_ayah ON bookmarks(surah_number, ayah_number);`
- `CREATE INDEX idx_bookmarks_created_at ON bookmarks(created_at DESC);`
- `CREATE INDEX idx_bookmarks_page_number ON bookmarks(cached_page_number);` (optional, for performance)

**SQL Creation (Updated Schema):**

```sql
CREATE TABLE IF NOT EXISTS bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  cached_page_number INTEGER,
  created_at TEXT NOT NULL,
  note TEXT,
  UNIQUE(surah_number, ayah_number)
);

CREATE INDEX IF NOT EXISTS idx_bookmarks_surah_ayah
  ON bookmarks(surah_number, ayah_number);

CREATE INDEX IF NOT EXISTS idx_bookmarks_created_at
  ON bookmarks(created_at DESC);
```

**Migration Required:**

- Existing bookmarks table (with `page_number`) must be migrated
- See Section 8.1 for migration strategy

---

## 5. Service Layer

### 5.1 Bookmarks Service

**File:** `lib/services/bookmarks_service.dart`

**Responsibilities:**

- Database operations (CRUD)
- Bookmark existence checking
- List retrieval with ordering

**Interface (Updated for Ayah-Based):**

```dart
abstract class BookmarksService {
  // Add bookmark by surah:ayah
  Future<void> addBookmark(int surahNumber, int ayahNumber);

  // Remove bookmark by surah:ayah
  Future<void> removeBookmark(int surahNumber, int ayahNumber);

  // Check if specific ayah is bookmarked
  Future<bool> isBookmarked(int surahNumber, int ayahNumber);

  // Get all bookmarks (sorted by creation date)
  Future<List<Bookmark>> getAllBookmarks({bool newestFirst = true});

  // Get bookmark by surah:ayah
  Future<Bookmark?> getBookmarkByAyah(int surahNumber, int ayahNumber);

  // Helper: Check if any ayah on a page is bookmarked (for UI status)
  Future<bool> isPageBookmarked(int pageNumber);

  // Clear all bookmarks
  Future<void> clearAllBookmarks();

  // Migration: Convert page-based bookmark to ayah-based
  Future<void> migratePageBookmark(int pageNumber);
}
```

**Implementation Details:**

- **`addBookmark(surah, ayah)`:**

  - Validates surah (1-114) and ayah numbers
  - Stores surah:ayah pair (unique constraint prevents duplicates)
  - Optionally calculates and stores `cached_page_number` for current layout

- **`isPageBookmarked(pageNumber)`:**
  - Helper method for UI status checking
  - Gets first ayah on page: `_getFirstAyahOnPage(pageNumber)`
  - Checks if that ayah is bookmarked: `isBookmarked(surah, ayah)`

**Implementation Details:**

- **Separate SQLite Database:** Uses dedicated `bookmarks.db` file in app documents directory
- **Database Location:** `{documentsDirectory}/bookmarks.db`
- **Database Version:** 1 (created in `onCreate` callback)
- **Initialization:** Lazy initialization via `_ensureInitialized()` method (called before each operation)
- **Database Connection:** Stored in `_db` field, checked for null before operations
- **Validation:** Page numbers validated to be between 1 and `totalPages` (604) in `addBookmark()`
- **Error Handling:** Exceptions caught and re-thrown with descriptive messages
- **Dependencies:**
  - `sqflite` - Database operations
  - `path` - Path joining utilities
  - `path_provider` - App documents directory access
- **Indexes:**
  - `idx_bookmarks_page_number` on `page_number`
  - `idx_bookmarks_created_at` on `created_at DESC`
- **Table/Column Names:** Uses `DbConstants` class:
  - `DbConstants.bookmarksTable` = 'bookmarks'
  - `DbConstants.pageNumberCol` = 'page_number'
  - `DbConstants.createdAtCol` = 'created_at'
  - `DbConstants.noteCol` = 'note'

### 5.2 Provider Integration

**File:** `lib/providers.dart`

**Riverpod Providers (Updated for Ayah-Based):**

```dart
// Provider for bookmarks service
@Riverpod(keepAlive: true)
BookmarksService bookmarksService(Ref ref) {
  return SqliteBookmarksService();
}

// Provider for checking if specific page is bookmarked (helper for UI)
@riverpod
Future<bool> isPageBookmarked(Ref ref, int pageNumber) async {
  final service = ref.watch(bookmarksServiceProvider);
  return service.isPageBookmarked(pageNumber);
}

// Provider for checking if specific ayah is bookmarked
@riverpod
Future<bool> isAyahBookmarked(Ref ref, int surahNumber, int ayahNumber) async {
  final service = ref.watch(bookmarksServiceProvider);
  return service.isBookmarked(surahNumber, ayahNumber);
}

// Notifier for bookmark operations (class name: BookmarksNotifier)
@Riverpod(keepAlive: true)
class BookmarksNotifier extends _$BookmarksNotifier {
  @override
  Future<List<Bookmark>> build() async {
    final service = ref.read(bookmarksServiceProvider);
    return service.getAllBookmarks();
  }

  // Toggle bookmark for current page (determines ayah first)
  Future<void> togglePageBookmark(int pageNumber) async {
    final dbService = ref.read(databaseServiceProvider);
    final firstAyah = await dbService._getFirstAyahOnPage(pageNumber);
    final surah = firstAyah['surah']!;
    final ayah = firstAyah['ayah']!;

    await toggleAyahBookmark(surah, ayah);

    // Invalidate page-specific provider
    ref.invalidate(isPageBookmarkedProvider(pageNumber));
  }

  // Toggle bookmark for specific ayah
  Future<void> toggleAyahBookmark(int surahNumber, int ayahNumber) async {
    final service = ref.read(bookmarksServiceProvider);
    final isBookmarked = await service.isBookmarked(surahNumber, ayahNumber);

    if (isBookmarked) {
      await service.removeBookmark(surahNumber, ayahNumber);
    } else {
      await service.addBookmark(surahNumber, ayahNumber);
    }

    // Invalidate to refresh list
    ref.invalidateSelf();
    ref.invalidate(isAyahBookmarkedProvider(surahNumber, ayahNumber));
  }

  // Remove bookmark by surah:ayah
  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    final service = ref.read(bookmarksServiceProvider);
    await service.removeBookmark(surahNumber, ayahNumber);
    ref.invalidateSelf();
    ref.invalidate(isAyahBookmarkedProvider(surahNumber, ayahNumber));
  }
}
```

**Usage:**

- Access list: `ref.watch(bookmarksProvider)` (auto-generated from `BookmarksNotifier`)
- Toggle bookmark for current page: `ref.read(bookmarksProvider.notifier).togglePageBookmark(pageNumber)`
- Toggle bookmark for specific ayah: `ref.read(bookmarksProvider.notifier).toggleAyahBookmark(surah, ayah)`
- Remove bookmark: `ref.read(bookmarksProvider.notifier).removeBookmark(surah, ayah)`

---

## 6. UI Components

### 6.1 Long-Press Gesture on Ayah

**Location:** `lib/widgets/mushaf_page_widget.dart` and `lib/widgets/line_widget.dart`

**Implementation:**

Each ayah widget must support long-press gesture detection:

```dart
GestureDetector(
  onLongPress: () {
    // Detect which ayah was pressed
    final selectedAyah = detectAyahFromTap(tapPosition);
    // Show highlight and context menu
    showAyahContextMenu(selectedAyah);
  },
  child: AyahWidget(ayah: ayah),
)
```

**Key Requirements:**

- Each ayah text widget wrapped in `GestureDetector` or `InkWell`
- Detect tap coordinates to identify specific ayah
- Use page layout data to determine ayah boundaries
- Handle edge cases (tap between ayat, partial visibility)

**Ayah Detection Logic:**

- Get tap position from gesture recognizer
- Query page layout to find ayah containing tap coordinates
- Use `getAyahAtPosition(x, y)` helper method
- If ambiguous (between ayat), select ayah whose center is closest

**Selection Screen Header Icon:**

**Location:** `lib/widgets/shared/app_header.dart`

**Implementation:**

```dart
AppHeader(
  title: _getScreenTitle(currentIndex),
  onSearchPressed: () { ... },
  onBookmarkPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BookmarksScreen()),
    );
  },
)
```

**Selection Screen Icon Details:**

- Position: **Right side** of header Row (after title Expanded, before back button if present)
- Icon: Always filled `Icons.bookmark`
- Size: `kAppHeaderIconSize` (24.0)
- Color: Grey (`Colors.grey.shade400` dark / `Colors.grey.shade600` light) - matches Settings/Search
- Tooltip: "العلامات المرجعية"
- Behavior: Navigates to `BookmarksScreen` on tap
- **Note:** NO bookmark icon on Mushaf Screen header - bookmarking done via long-press only

### 6.2 Bookmarks Screen

**File:** `lib/screens/bookmarks_screen.dart`

**Actual Implementation:**

**Structure:**

```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        AppHeader(
          title: '',
          showBackButton: true,
        ),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: BookmarksListView(),
          ),
        ),
      ],
    ),
  ),
)
```

**Features:**

- Full screen dedicated to bookmarks list
- Uses `AppHeader` with `showBackButton: true`
- Empty title string
- Wraps `BookmarksListView` in `Directionality(textDirection: TextDirection.rtl)`
- Contains `BookmarksListView` widget

### 6.3 Bookmarks List Widget

**File:** `lib/widgets/bookmarks_list_view.dart`

**Actual Implementation:**

**Features:**

- List of bookmark cards using `ListView.builder`
- Swipe-to-delete gesture (implemented in `BookmarkItemCard`)
- Empty state widget (`_EmptyBookmarksState`)
- Loading state (CircularProgressIndicator)
- Error state handling with user-friendly Arabic message
- RTL text direction set at parent level (`BookmarksScreen`)

**Implementation:**

```dart
ConsumerWidget(
  build: (context, ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    return bookmarksAsync.when(
      data: (bookmarks) {
        if (bookmarks.isEmpty) return _EmptyBookmarksState();
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            return BookmarkItemCard(bookmark: bookmarks[index]);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(...), // Error UI
    );
  },
)
```

**Empty State:**

- Icon: `Icons.bookmark_border` (64px, muted color)
- Title: "لا توجد علامات مرجعية بعد" (20px, bold)
- Description: "ابدأ القراءة واحفظ صفحاتك المفضلة للوصول إليها بسرعة لاحقاً" (16px)
- Action Button: "ابدأ القراءة" (navigates to MushafScreen page 1)

**Error State:**

- Icon: `Icons.error_outline` (48px, error color)
- Message: "حدث خطأ أثناء تحميل العلامات المرجعية" (Arabic)

### 6.4 Bookmark Item Card

**File:** `lib/widgets/bookmark_item_card.dart`

**Actual Implementation:**

**Features:**

- RTL layout using `textDirection: TextDirection.rtl`
- Swipe-to-delete with `Dismissible` widget
- Dismiss direction: `DismissDirection.endToStart` (swipe right to delete in RTL)
- Tap to navigate to bookmarked page
- Displays: Bookmark icon + Page number, Surah glyph, Relative date
- Loading state while fetching page data
- Theme-aware styling

**Layout Structure (Actual Implementation):**

```dart
Card(
  child: Dismissible(
    direction: DismissDirection.endToStart, // Swipe right (RTL)
    background: Container(...), // Delete button on left
    child: InkWell(
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Content (Expanded)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // START (RTL natural)
              textDirection: TextDirection.rtl,
              children: [
                // Row: Bookmark icon + Page number
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.bookmark, size: 20),
                    Text('الصفحة ١٥', textAlign: TextAlign.left),
                  ],
                ),
                // Surah glyph (28px)
                Text(surahGlyph, textAlign: TextAlign.left),
                // Date (right-aligned)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(date, textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
          // Right: Chevron icon
          Icon(Icons.chevron_right, size: 24),
        ],
      ),
    ),
  ),
)
```

**RTL Layout Notes (Actual Implementation):**

- Card wrapped in `Directionality(textDirection: TextDirection.rtl)` at parent level (`BookmarksListView`)
- Content Column uses `crossAxisAlignment: CrossAxisAlignment.start` (which is RTL natural start = right side visually)
- Text widgets use `textAlign: TextAlign.left` (which aligns to RTL start = right side visually)
- Date line uses `Align(alignment: Alignment.centerRight)` with `TextAlign.right` for explicit right alignment
- Chevron icon (`Icons.chevron_right`) positioned on right side (trailing)
- Swipe gesture: Swipe **right** to reveal delete button on **left** side

**Content Display (Updated for Ayah-Based):**

- **Line 1:** Bookmark icon (20px) + **Verse reference** (22px, e.g., "٢:٢٥٥") + **Page number in parentheses** (optional, e.g., "(الصفحة ٣٠٢)")
- **Line 2:** Surah name glyph (28px, surah font) or loading indicator
- **Line 3:** Relative date (15px, right-aligned, muted color)

**Display Format:**

- Primary: Verse reference (e.g., "٢:٢٥٥" - Surah 2, Ayah 255)
- Secondary: Page number in parentheses (dynamically calculated for current layout)
- Example: "٢:٢٥٥ (الصفحة ٣٠٢)" or just "٢:٢٥٥" if page number not shown

**Data Source:**

- Verse reference: From bookmark model (`bookmark.verseReference` or `bookmark.surahNumber:bookmark.ayahNumber`)
- Page number: Calculate using `getPageForAyah(bookmark.surahNumber, bookmark.ayahNumber)` for current layout
- Uses `pageDataProvider(pageNumber)` to fetch page data for surah glyph display
- Shows `LinearProgressIndicator` while loading page data
- Date formatted using `formatRelativeDate()` helper function (`lib/utils/helpers.dart`)

**Swipe-to-Delete:**

- Uses `Dismissible` widget with `DismissDirection.endToStart` (swipe right in RTL)
- Background: Red container with `Icons.delete_outline` on left side
- On dismiss: Calls `removeBookmark(surahNumber, ayahNumber)` and shows Arabic snackbar "تم حذف العلامة المرجعية"
- No confirmation dialog (direct deletion)

### 6.5 Ayah Context Menu Widget

**File:** `lib/widgets/ayah_context_menu.dart` (new file)

**Widget:** `AyahContextMenu` extends `StatelessWidget`

**Features:**

- Context menu displayed after long-press on ayah
- RTL-aware positioning near tap location
- Shows bookmark/unbookmark option based on current state
- Dismissible on tap outside or back button

**Implementation Details:**

```dart
class AyahContextMenu extends StatelessWidget {
  final int surahNumber;
  final int ayahNumber;
  final bool isBookmarked;
  final Offset tapPosition;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      position: PopupMenuPosition.over, // Position near tap
      child: Container(), // Transparent overlay
      itemBuilder: (context) => [
        PopupMenuItem(
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(isBookmarked ? Icons.bookmark_remove : Icons.bookmark),
              const SizedBox(width: 8),
              Text(isBookmarked ? 'إزالة العلامة المرجعية' : 'حفظ'),
            ],
          ),
          onTap: () => _handleBookmark(),
        ),
      ],
    );
  }
}
```

**Alternative:** Use `Overlay` widget for more control over positioning and styling

**Styling:**

- Rounded corners (16px radius)
- Shadow/elevation for depth
- RTL text direction
- Theme-aware colors

---

## 7. Integration Points

### 7.1 Selection Screen

**File:** `lib/screens/selection_screen.dart`

**Changes Required:**

1. Add bookmark icon to `AppHeader` in Selection Screen
   - Pass `onBookmarkPressed` callback to header
   - **Icon must appear on RIGHT side (trailing side), separated from Settings/Search**
   - Navigate to Bookmarks Screen when tapped
2. **DO NOT modify** bottom navigation order (السور | الأجزاء | الصفحات - indices 0, 1, 2)
3. **DO NOT add** Bookmarks tab to bottom navigation
4. Bookmarks Screen accessed via header icon only

### 7.2 Mushaf Screen

**File:** `lib/screens/mushaf_screen.dart`

**Integration (Long-Press Approach):**

**Key Changes:**

1. **REMOVE** `BookmarkIconButton` widget from `AppHeader.trailing` parameter
2. **REMOVE** bookmark icon from Mushaf Screen header
3. **ADD** long-press gesture detection to ayah widgets in `MushafPageWidget`

**Mushaf Screen Header:**

```dart
AppHeader(
  title: asyncPageData.when(...),
  // NO trailing parameter - no bookmark icon
)
```

**Long-Press Integration:**

- Long-press gesture handled in `MushafPageWidget` or `LineWidget`
- Each ayah widget wrapped with `GestureDetector` or `InkWell`
- On long-press: Detect ayah, show highlight, display context menu
- On "Bookmark" tap: Call `bookmarksProvider.notifier.toggleAyahBookmark(surah, ayah)`
- Provider invalidation handled by `BookmarksNotifier` after bookmark toggle

**Ayah Detection:**

- Use page layout data to identify which ayah contains tap coordinates
- Extract surah and ayah numbers from selected ayah
- Handle edge cases (tap between ayat, partial visibility)

### 7.3 App Header (Selection Screen Only)

**File:** `lib/widgets/shared/app_header.dart`

**Header Structure:**

```
Row([
  // Left: Settings/Search icons
  Row([Settings, Search]),
  // Center: Title (Expanded)
  Expanded(title),
  // Right: Bookmark icon (Selection only) OR back button
  if (onBookmarkPressed != null && trailing == null) BookmarkIcon,
  if (showBackButton) BackButton,
])
```

**Mushaf Screen:**

- **NO bookmark icon** - bookmarking done via long-press on ayah only
- Header remains clean with Settings and Search icons
- No `trailing` parameter needed for bookmarks

**Selection Screen:**

- Uses `onBookmarkPressed` callback parameter
- Icon appears on right side (after title, before back button)
- Always filled `Icons.bookmark`
- Grey color matching Settings/Search
- Tooltip: "العلامات المرجعية"
- Condition: `onBookmarkPressed != null && trailing == null`

---

## 8. Technical Implementation

### 8.1 Database Migration

**Migration Required for Ayah-Based Bookmarks:**

**Current State:** Existing bookmarks table has `page_number` column
**Target State:** Bookmarks table with `surah_number` and `ayah_number` columns

**Migration Strategy:**

**Phase 1: Add Ayah Support (Backward Compatible)**

1. Add `surah_number` and `ayah_number` columns to database (nullable initially)
2. Keep `page_number` column (deprecated but not removed)
3. New bookmarks: Store both ayah + cached page
4. Old bookmarks: Migrate on first access

**Phase 2: Migrate Existing Bookmarks**

1. On app launch: Check for bookmarks with null `surah_number`
2. For each old bookmark:
   - Query: `_getFirstAyahOnPage(oldBookmark.pageNumber)`
   - Extract: `surah` and `ayah`
   - Update: Set `surah_number` and `ayah_number`
3. Validation: Verify all bookmarks have ayah data

**Phase 3: Remove Page-Based Logic (Future)**

1. After all bookmarks migrated
2. Remove `page_number` column (future app version)
3. Remove deprecated functions

**Database Migration Code:**

```dart
// In _ensureInitialized() or separate migration method
Future<void> _migrateToAyahBased() async {
  if (_db == null) throw StateError('Database not initialized');

  // Check if migration needed (column doesn't exist)
  final tableInfo = await _db!.rawQuery("PRAGMA table_info(bookmarks)");
  final hasSurahNumber = tableInfo.any((col) => col['name'] == 'surah_number');

  if (!hasSurahNumber) {
    // Add new columns
    await _db!.execute('ALTER TABLE bookmarks ADD COLUMN surah_number INTEGER');
    await _db!.execute('ALTER TABLE bookmarks ADD COLUMN ayah_number INTEGER');
    await _db!.execute('ALTER TABLE bookmarks ADD COLUMN cached_page_number INTEGER');

    // Migrate existing bookmarks
    final oldBookmarks = await _db!.query('bookmarks',
        columns: ['id', 'page_number']);

    final dbService = DatabaseService();
    await dbService.init();

    for (final bookmark in oldBookmarks) {
      final pageNumber = bookmark['page_number'] as int;
      try {
        final firstAyah = await dbService._getFirstAyahOnPage(pageNumber);
        final surah = firstAyah['surah']!;
        final ayah = firstAyah['ayah']!;

        await _db!.update(
          'bookmarks',
          {
            'surah_number': surah,
            'ayah_number': ayah,
            'cached_page_number': pageNumber,
          },
          where: 'id = ?',
          whereArgs: [bookmark['id']],
        );
      } catch (e) {
        // Log error but continue migration
        print('Error migrating bookmark ${bookmark['id']}: $e');
      }
    }

    // Create new unique constraint and indexes
    // Note: SQLite doesn't support DROP CONSTRAINT, so we'll handle duplicates in application logic
    await _db!.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_bookmarks_surah_ayah
      ON bookmarks(surah_number, ayah_number)
    ''');
  }
}
```

**Database File:**

- Path: `{documentsDirectory}/bookmarks.db`
- Created using `path_provider` package
- Accessible via `getApplicationDocumentsDirectory()`

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

- **Prevention:** UNIQUE constraint on `(surah_number, ayah_number)` in database
- **Behavior:** If user tries to bookmark same ayah twice, toggle removes it (or updates timestamp)
- **Error Handling:** Catch UNIQUE constraint violation gracefully
- **Recommendation:** Update timestamp on duplicate (user may have "re-bookmarked" intentionally)

### 9.2 Invalid Ayah References

- **Validation:**
  - Ensure surah numbers are between 1 and 114
  - Ensure ayah numbers are valid for the surah
  - Query database to confirm ayah exists before storing
- **Error Handling:** Show error message "الآية غير موجودة" if invalid ayah attempted

### 9.2.1 Page-to-Ayah Lookup Failures

- **Issue:** What if `_getFirstAyahOnPage()` fails?
- **Solution:**
  - Fallback: Try next ayah on page
  - If all fail: Show error, don't bookmark
  - Log error for debugging

### 9.2.2 Ayah-to-Page Lookup Failures

- **Issue:** What if `getPageForAyah()` fails (ayah not found in current layout)?
- **Solution:**
  - This shouldn't happen (ayah exists in all layouts)
  - If it does: Show error "لا يمكن العثور على الصفحة"
  - Bookmark remains valid, user can try again after checking layout

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

✅ User can long-press on any ayah in Mushaf Screen to bookmark it
✅ Long-press gesture detected reliably (400-500ms duration)
✅ Selected ayah highlights visually when long-pressed
✅ Context menu appears near tap location with "Bookmark" option
✅ Bookmark stored as surah:ayah pair (universal across layouts)
✅ Bookmark icon always visible (filled grey) in Selection Screen header
✅ User can access bookmarks by tapping header icon in Selection Screen
✅ User can view all bookmarks in dedicated full-screen list
✅ Each bookmark displays verse reference (e.g., "٢:٢٥٥") as primary identifier
✅ Page number shown dynamically for current layout (secondary information)
✅ User can navigate to bookmarked ayah from list (works across all layouts)
✅ User can remove bookmark via long-press on bookmarked ayah (context menu shows "Remove bookmark") or swipe-to-delete in list
✅ Bookmarks persist across app restarts
✅ Bookmark state updates immediately when toggled
✅ No duplicate bookmarks (same ayah)
✅ Empty state displays when no bookmarks exist
✅ Bookmarks list uses proper RTL layout with right-aligned content
✅ Old page-based bookmarks migrated to ayah-based on app launch
✅ Ayah boundary detection works accurately (identifies correct ayah from tap coordinates)

### UI/UX Criteria

✅ Long-press gesture doesn't conflict with page swiping
✅ Ayah highlight appears smoothly with fade-in animation
✅ Context menu positioned appropriately (doesn't block text)
✅ List items have appropriate spacing and typography
✅ Swipe-to-delete works smoothly
✅ Colors and styles match app theme
✅ RTL layout works correctly
✅ Loading states are handled gracefully
✅ Error states show user-friendly messages
✅ Confirmation snackbar appears after bookmarking/unbookmarking

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
- ~~**Ayah-Level Bookmarks:** Bookmark specific verses (not just pages)~~ ✅ **IMPLEMENTED**
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

**Actual Implementation:**

### Required Dependencies

All dependencies are already in the project:

- **`flutter_riverpod`** - State management (providers, AsyncValue)
- **`sqflite`** - SQLite database operations
- **`path`** - Path joining utilities (used for database file path)
- **`path_provider`** - Access to app documents directory
- **Material Design icons** - Built-in Flutter icons (`Icons.bookmark`, `Icons.bookmark_border`, etc.)

### No New Dependencies Required

All required packages are already available in the project.

---

## 15. Implementation Checklist

**Status:** 📋 Ready for Implementation (Long-Press Ayah Bookmarking)

### Phase 1: Database & Service Layer

- [ ] Update `Bookmark` model class (`lib/models.dart`) - Add surahNumber, ayahNumber, remove pageNumber (if not already done)
- [ ] Update database schema (in `SqliteBookmarksService`) - Add columns, migration logic (if not already done)
- [ ] Update `BookmarksService` interface - Change methods to use surah:ayah (if not already done)
- [ ] Update `SqliteBookmarksService` implementation - Implement ayah-based CRUD (if not already done)
- [ ] Add database migration code - Migrate existing page-based bookmarks (if not already done)
- [ ] Remove `isPageBookmarked()` helper method (no longer needed for header icon)
- [ ] Write unit tests for service layer (recommended for future)

### Phase 2: State Management

- [ ] Update Riverpod providers for bookmarks (`lib/providers.dart`)
- [ ] Update `BookmarksNotifier` class - Keep `toggleAyahBookmark()`, remove `togglePageBookmark()`
- [ ] Remove `isPageBookmarked` provider (no longer needed)
- [ ] Keep `isAyahBookmarked` provider - Direct ayah checking
- [ ] Update provider invalidation logic
- [ ] Write tests for providers (recommended for future)

### Phase 3: UI Components (Long-Press Implementation)

- [ ] **REMOVE** `BookmarkIconButton` widget from Mushaf Screen (no longer used)
- [ ] **ADD** long-press gesture detection to ayah widgets in `MushafPageWidget` or `LineWidget`
- [ ] Implement ayah boundary detection - Identify which ayah contains tap coordinates
- [ ] Create ayah highlight widget - Visual feedback when ayah is selected
- [ ] Create `AyahContextMenu` widget - Context menu with "Bookmark" / "Remove bookmark" option
- [ ] Update `BookmarksListView` widget - No changes needed (uses bookmark model)
- [ ] Update `BookmarkItemCard` widget - Display verse reference instead of page number (if not already done)
- [ ] Add page number calculation - Use `getPageForAyah()` to show current layout's page (if not already done)
- [ ] Update navigation logic - Use `getPageForAyah()` instead of direct page number (if not already done)
- [ ] Update swipe-to-delete - Use `removeBookmark(surah, ayah)` instead of `removeBookmark(page)` (if not already done)
- [ ] Create empty state widget (`_EmptyBookmarksState`) - Already implemented
- [ ] Implement swipe-to-delete gesture (via `Dismissible`) - Already implemented
- [ ] Write widget tests (recommended for future)

### Phase 4: Integration (Long-Press on Mushaf Screen)

- [x] Integrate bookmark icon into `AppHeader` (`lib/widgets/shared/app_header.dart`) - Selection Screen only
  - [x] Add `onBookmarkPressed` parameter for Selection Screen
  - [ ] **REMOVE** `trailing` parameter usage for `BookmarkIconButton` on Mushaf Screen
  - [x] **Selection Screen:** Uses `onBookmarkPressed` callback on right side
  - [x] Icon shows filled grey on Selection Screen
  - [ ] **Mushaf Screen:** NO bookmark icon - removed from header
- [x] Create `BookmarksScreen` (`lib/screens/bookmarks_screen.dart`)
- [x] Connect Selection Screen header to navigate to Bookmarks Screen
- [ ] **ADD** long-press gesture to ayah widgets in Mushaf Screen
  - [ ] Wrap ayah widgets with `GestureDetector` or `InkWell`
  - [ ] Implement ayah detection from tap coordinates
  - [ ] Show highlight on long-press
  - [ ] Display context menu with bookmark option
  - [ ] Handle bookmark toggle via `BookmarksNotifier.toggleAyahBookmark()`
- [ ] Update navigation logic in `navigateToMushafPage()` helper - Use `getPageForAyah()` instead of direct page number
- [ ] Update `BookmarkItemCard` tap handler - Navigate using ayah lookup
- [x] **DO NOT modify** bottom navigation order (maintained)

### Phase 5: Long-Press Polish & Testing

- [ ] Test long-press gesture detection (doesn't conflict with page swiping)
- [ ] Test ayah boundary detection accuracy (tap coordinates to ayah mapping)
- [ ] Test context menu positioning (doesn't block text, RTL-aware)
- [ ] Test highlight animation smoothness
- [ ] Test bookmark toggle via context menu
- [ ] Test unbookmark via long-press on bookmarked ayah
- [ ] Verify bookmarks work across layout switches
- [ ] Add animations and transitions (highlight fade-in, menu appearance)
- [ ] Theme integration (theme-aware colors and styling for highlight/menu)
- [ ] RTL layout (proper text direction and alignment for context menu)
- [ ] Onboarding tooltip (optional: show "Long-press any ayah to bookmark" on first Mushaf Screen visit)
- [ ] Performance optimization (indexed database, cached page numbers)
- [ ] Integration testing (recommended for future)
- [ ] User acceptance testing (recommended for future)

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
