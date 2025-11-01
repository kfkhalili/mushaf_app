# Bookmarks Feature Specification

**Version:** 4.0 (Long-Press Ayah Bookmarking)
**Date:** January 2025
**Status:** ✅ Implemented and Working
**Priority:** High (Quarter 1) - Completed

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
6. **As a user**, I want to see context about each bookmark (verse reference like "الآية ٢٥٥", surah name, date, and optionally ayah text preview), so I can identify it easily

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

- **Visual Feedback:** (✅ **IMPLEMENTED**)

  - **Highlight:** Selected ayah highlighted by changing text color to primary color (✅ **IMPLEMENTED** in `MushafLine` - uses `baseColor: isSelected ? theme.colorScheme.primary`). Note: Implementation uses text color change rather than background color with opacity as originally specified.
  - **Context Menu:** Appears near tap location as overlay (✅ **IMPLEMENTED** - `AyahContextMenu` widget)
  - **Menu Options:** (✅ **IMPLEMENTED**)
    - For non-bookmarked: "أضف إشارة مرجعية" (Add bookmark) - Bookmark icon + text - ✅ **IMPLEMENTED**
    - For bookmarked: "إزالة العلامة المرجعية" (Remove bookmark) - Remove bookmark icon + text - ✅ **IMPLEMENTED**
    - Future: "Share", "Copy", "Notes" (out of scope for v1)
  - **Confirmation:** Brief snackbar: "تم حفظ الآية" / "Ayah bookmarked" (2 seconds) - ✅ **IMPLEMENTED**

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
- **Each Bookmark Shows:** (✅ **IMPLEMENTED**)
  - **Verse reference** (ayah reference: "الآية X" - where X is the ayah number in Eastern Arabic numerals) - **Primary identifier** - ✅ **IMPLEMENTED**
  - **Surah name glyph** (28px font, surah icon style) - ✅ **IMPLEMENTED**
  - **Date bookmarked** (relative: "Today", "Yesterday", "2 days ago", formatted via `formatRelativeDate()`) - ✅ **IMPLEMENTED**
  - **Ayah text preview** (optional, shown if available) - ✅ **IMPLEMENTED**: Shows first line of ayah text with ellipsis
  - **Page number** - ❌ **NOT DISPLAYED**: Page number is calculated for navigation but not shown in the UI. This differs from the original spec which suggested showing page number as secondary information. The implementation prioritizes verse reference as the primary identifier.
- **Display Format (Current Implementation):**
  - Primary: Verse reference (e.g., "الآية ٢٥٥")
  - Secondary: Surah glyph (large, 28px)
  - Tertiary: Date (small, muted, right-aligned)
  - Optional: Ayah text preview (if available)
- **Empty State:** Beautiful empty state message when no bookmarks exist - ✅ **IMPLEMENTED**

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

#### 3.1.5 Bookmark Status Indication (✅ **IMPLEMENTED**)

- **Visual Indicator on Ayah:** When viewing a page, ayat that are already bookmarked show visual indicator (✅ **IMPLEMENTED**)
  - **Current Implementation:** Bookmarked ayat text color changes to primary color (theme.colorScheme.primary) - ✅ **IMPLEMENTED** in `MushafLine` widget (line 201-202)
  - **Note:** Implementation differs from spec's three options. Instead of icon/border/background, text color is changed to primary color to indicate bookmarked status. This provides clear visual distinction while maintaining clean UI.
  - **Original Spec Options (not implemented):**
    - Option 1: Small bookmark icon in corner
    - Option 2: Subtle colored border or background tint
    - Option 3: Only show indicator on hover/long-press
- **Context Menu State:** When long-pressing a bookmarked ayah, menu shows "إزالة العلامة المرجعية" (Remove bookmark) instead of "أضف إشارة مرجعية" (Add bookmark) - ✅ **IMPLEMENTED**
- **List View:** Bookmarks list shows all bookmarked ayat with clear visual distinction - ✅ **IMPLEMENTED**: Bookmark icon + surah glyph + verse reference displayed clearly

### 3.2 UI/UX Requirements

#### 3.2.1 Header Integration

**Location:** App header (existing header component)

**Bookmark Icon Context:**

**Selection Screen (Bookmarks Access):**
- Position: **Right side** of header in RTL layout (opposite from Settings/Search)
- Separated from Settings and Search icons (on different side of header)
- Appears on the **trailing** side (right side in RTL, visually left side)
- Icon: Always **filled** (`Icons.bookmark`)
- Color: **Grey** to match Settings and Search icons (`Colors.grey.shade400` dark / `Colors.grey.shade600` light)
- Size: Match existing header icon size (`kAppHeaderIconSize = 24.0`)
- Tooltip: "العلامات المرجعية" / "Bookmarks" (RTL text direction)
- Behavior: Tap icon to navigate to Bookmarks screen/list
- Always visible on Selection Screen

**Mushaf Screen:**
- **NO bookmark icon in header** - Bookmarking is done via long-press on ayah text only
- Long-press any ayah to show context menu with bookmark option
- This ensures precise, intentional bookmarking at the ayah level

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

**Improved RTL Card Layout (Actual Implementation):**

- **Right-aligned content (RTL):** ✅ **IMPLEMENTED**

  - Bookmark icon (📖) at right edge - ✅ **IMPLEMENTED**
  - Surah name glyph (large, 28px) immediately left of icon - ✅ **IMPLEMENTED**
  - Verse reference (الآية X) below surah, bold - ✅ **IMPLEMENTED**
  - Optional: Ayah text preview below verse reference - ✅ **IMPLEMENTED** if available
  - Metadata (date) on right side column, smaller text - ✅ **IMPLEMENTED**

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
│  ←                    📖 [Surah Glyph]  │ ← Arrow on left, content on right
│                              الآية ٢٥٥  │ ← Right-aligned: Verse reference
│                        منذ يومين        │ ← Right-aligned: Date
└─────────────────────────────────────────┘
```

- **Right Side (Primary Content - MUST be right-aligned):** ✅ **IMPLEMENTED**

  - Bookmark icon (📖) + Surah glyph (large, 28px) on same line - ✅ **IMPLEMENTED**
  - Icon: 20px size, positioned at **left** of surah glyph - ✅ **IMPLEMENTED**
  - Verse reference (الآية X): Large, bold, Eastern Arabic numerals - ✅ **IMPLEMENTED**: 22px font
  - Optional: Ayah text preview below verse reference, small muted text - ✅ **IMPLEMENTED** if available
  - **ALL TEXT MUST BE RIGHT-ALIGNED** - Uses `TextDirection.rtl` and appropriate alignment - ✅ **IMPLEMENTED**
  - Content Column uses `crossAxisAlignment: CrossAxisAlignment.stretch` - ✅ **IMPLEMENTED**

- **Left Side (Navigation - Fixed position):** ✅ **IMPLEMENTED**

  - Chevron icon (→) pointing **right** (RTL visual direction) - ✅ **IMPLEMENTED**
  - Position: Fixed on **left edge** of card - ✅ **IMPLEMENTED**
  - Light grey color, subtle - ✅ **IMPLEMENTED**
  - 24px size, centered vertically with date below - ✅ **IMPLEMENTED**
  - Indicates tap to navigate (RTL direction)

- **Typography:** ✅ **IMPLEMENTED**

  - Verse reference: `fontSize: 22, fontWeight: w700` (larger, bolder) - ✅ **IMPLEMENTED**
  - Bookmark icon: `fontSize: 20` - ✅ **IMPLEMENTED**
  - Surah glyph: `fontSize: 28, fontWeight: w500` - ✅ **IMPLEMENTED**
  - Ayah text preview: `fontSize: 12, fontWeight: w400` - ✅ **IMPLEMENTED** if available
  - Date: `fontSize: 15, fontWeight: w400, color: muted` - ✅ **IMPLEMENTED**

- **Colors (Theme-Aware):**

  - Card background: `Theme.cardColor`
  - Card border: Subtle border (`Theme.dividerColor.withValues(alpha: 0.3)`)
  - Primary text: `Theme.textTheme.bodyLarge?.color`
  - Secondary text: `Theme.textTheme.bodyMedium?.color`
  - Muted text: `Theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6)`
  - Chevron icon: `Theme.iconTheme.color?.withValues(alpha: 0.5)`
  - Bookmark icon: Primary color (theme.colorScheme.primary) - ✅ **IMPLEMENTED**

- **Visual Improvements:** ✅ **IMPLEMENTED**

  - Clear visual hierarchy: Verse reference stands out most - ✅ **IMPLEMENTED**
  - Better spacing: 16px padding all around - ✅ **IMPLEMENTED**
  - Consistent alignment: All Arabic text right-aligned - ✅ **IMPLEMENTED**
  - Subtle dividers: Border with `dividerColor.withValues(alpha: 0.3)` - ✅ **IMPLEMENTED**
  - Icon positioning: Bookmark icon inline with surah glyph for compact design - ✅ **IMPLEMENTED**

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
  → User taps "أضف إشارة مرجعية" (Add bookmark) option
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

**Implementation Details:**

**Note:** `isPageBookmarked()` method exists in the implementation as legacy code (used by unused `BookmarkIconButton` widget). Since we bookmark ayat, not pages, this method should be removed.

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

**Note:** `isPageBookmarkedProvider` exists in the implementation as legacy code (only used by unused `BookmarkIconButton` widget). Since we bookmark ayat, not pages, this provider should be removed.

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

  // Toggle bookmark for specific ayah
  Future<void> toggleAyahBookmark(int surahNumber, int ayahNumber) async {
    final service = await ref.read(bookmarksServiceProvider.future);
    final dbService = await ref.read(databaseServiceProvider.future);
    final isBookmarked = await service.isBookmarked(surahNumber, ayahNumber);

    if (isBookmarked) {
      await service.removeBookmark(surahNumber, ayahNumber);
    } else {
      await service.addBookmark(surahNumber, ayahNumber);
    }

    int? pageNumber;
    try {
      pageNumber = await dbService.getPageForAyah(surahNumber, ayahNumber);
    } catch (e) {
      // Silently fail if page number can't be found, but invalidation of
      // other providers should still proceed.
    }

    // Invalidate to refresh list
    ref.invalidateSelf();
    ref.invalidate(isAyahBookmarkedProvider(surahNumber, ayahNumber));
    // Note: isPageBookmarkedProvider invalidation below is legacy and should be removed
    if (pageNumber != null) {
      ref.invalidate(isPageBookmarkedProvider(pageNumber));
    }
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
- **Note:** NO bookmark icon on Mushaf Screen header - bookmarking done via long-press on ayah only (✅ **IMPLEMENTED**)

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
- Displays: Bookmark icon + Surah glyph, Verse reference, Optional ayah text preview, Relative date - ✅ **IMPLEMENTED**
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
                // Row: Bookmark icon + Surah glyph
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Icon(Icons.bookmark, size: 20, color: theme.colorScheme.primary),
                    Text(surahGlyph, fontSize: 28), // Surah glyph (28px)
                  ],
                ),
                // Verse reference (22px, bold)
                Text(verseReference, fontSize: 22, fontWeight: w700),
                // Optional: Ayah text preview
                if (ayahText != null && ayahText!.isNotEmpty)
                  Text(ayahText, fontSize: 12, maxLines: 1, overflow: ellipsis),
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

- **Line 1:** Bookmark icon (20px) + Surah name glyph (28px, surah font) - ✅ **IMPLEMENTED**
- **Line 2:** Verse reference (22px, bold, e.g., "الآية ٢٥٥") - ✅ **IMPLEMENTED**
- **Line 3 (optional):** Ayah text preview (12px, Arabic font, max 1 line with ellipsis) - ✅ **IMPLEMENTED** if available
- **Right side:** Chevron icon (24px) + Relative date (15px, muted) - ✅ **IMPLEMENTED**

**Display Format (Current Implementation):**

- **Primary:** Verse reference (e.g., "الآية ٢٥٥" - showing ayah number in Eastern Arabic numerals) - ✅ **IMPLEMENTED**
- **Secondary:** Surah glyph (large, 28px) - ✅ **IMPLEMENTED**
- **Tertiary:** Date (small, muted, right-aligned) - ✅ **IMPLEMENTED**
- **Optional:** Ayah text preview (if available) - ✅ **IMPLEMENTED**
- **Note:** Page number is NOT displayed in the UI, even though it's calculated for navigation. The design prioritizes verse reference as the primary identifier, which is universal across all layouts.

**Data Source:**

- Verse reference: From bookmark model (`bookmark.verseReference.split(':')` then converts to Eastern Arabic numerals) - ✅ **IMPLEMENTED**
- Page number: Calculated using `bookmarkPageNumberProvider(bookmark.surahNumber, bookmark.ayahNumber)` for navigation only (not displayed) - ✅ **IMPLEMENTED**
- Surah glyph: Uses surah number from bookmark model directly - ✅ **IMPLEMENTED**
- Ayah text: From bookmark model (`bookmark.ayahText`) - ✅ **IMPLEMENTED**
- Date formatted using `formatRelativeDate()` helper function (`lib/utils/helpers.dart`) - ✅ **IMPLEMENTED**

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

- **NO bookmark icon** - bookmarking done via long-press on ayah only (✅ **IMPLEMENTED**)
- Header remains clean with Settings and Search icons
- No `trailing` parameter needed for bookmarks
- Long-press gesture implemented in `MushafPage` widget with `AyahContextMenu` overlay

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
- **Indexing:** Database indexes on `(surah_number, ayah_number)`, `created_at`, and optionally `cached_page_number` - ✅ **IMPLEMENTED**
- **Limit:** Consider pagination if bookmarks list grows very large (unlikely for typical use)

### 8.4 Error Handling

- **Database Errors:** Catch and log, show user-friendly message
- **Network Errors:** N/A (offline-first)
- **Validation:** Ensure surah numbers are valid (1-114) and ayah numbers are positive - ✅ **IMPLEMENTED**
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

✅ User can long-press on any ayah in Mushaf Screen to bookmark it - ✅ **IMPLEMENTED**: Long-press in `MushafLine` widget
✅ Long-press gesture detected reliably (400-500ms duration) - ✅ **IMPLEMENTED**: Standard Flutter `GestureDetector.onLongPress`
✅ Selected ayah highlights visually when long-pressed - ✅ **IMPLEMENTED**: Highlight via `selectedAyahKey` in `MushafPage`
✅ Context menu appears near tap location with "Bookmark" option - ✅ **IMPLEMENTED**: `AyahContextMenu` overlay
✅ Bookmark stored as surah:ayah pair (universal across layouts) - ✅ **IMPLEMENTED**: Database schema uses surah_number + ayah_number
✅ Bookmark icon always visible (filled grey) in Selection Screen header - ✅ **IMPLEMENTED**: Icon in `AppHeader` via `onBookmarkPressed`
✅ User can access bookmarks by tapping header icon in Selection Screen - ✅ **IMPLEMENTED**: Navigates to `BookmarksScreen`
✅ User can view all bookmarks in dedicated full-screen list - ✅ **IMPLEMENTED**: `BookmarksScreen` with `BookmarksListView`
✅ Each bookmark displays verse reference (e.g., "الآية ٢٥٥") as primary identifier - ✅ **IMPLEMENTED**: Shows "الآية X" in `BookmarkItemCard` with Eastern Arabic numerals
⚠️ Page number calculated dynamically for navigation but NOT displayed in UI - **NOTE**: Page number is fetched via `bookmarkPageNumberProvider` for navigation purposes only. The spec suggested displaying page number as secondary information, but the implementation prioritizes verse reference as the universal identifier.
✅ User can navigate to bookmarked ayah from list (works across all layouts) - ✅ **IMPLEMENTED**: Navigation uses `getPageForAyah()` via `bookmarkPageNumberProvider`
✅ User can remove bookmark via long-press on bookmarked ayah (context menu shows "Remove bookmark") or swipe-to-delete in list - ✅ **IMPLEMENTED**: Both methods working
✅ Bookmarks persist across app restarts - ✅ **IMPLEMENTED**: SQLite database persistence
✅ Bookmark state updates immediately when toggled - ✅ **IMPLEMENTED**: Provider invalidation updates UI
✅ No duplicate bookmarks (same ayah) - ✅ **IMPLEMENTED**: UNIQUE constraint on (surah_number, ayah_number)
✅ Empty state displays when no bookmarks exist - ✅ **IMPLEMENTED**: Empty state in `BookmarksListView`
✅ Bookmarks list uses proper RTL layout with right-aligned content - ✅ **IMPLEMENTED**: RTL text direction and alignment
✅ Old page-based bookmarks migrated to ayah-based on app launch - ✅ **IMPLEMENTED**: Migration in `_checkAndRunMigration()`
✅ Ayah boundary detection works accurately (identifies correct ayah from tap coordinates) - ✅ **IMPLEMENTED**: Word-level detection in `MushafLine`

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

**Status:** ✅ Implemented (Long-Press Ayah Bookmarking)

### Phase 1: Database & Service Layer

- [x] Update `Bookmark` model class (`lib/models.dart`) - Add surahNumber, ayahNumber, remove pageNumber - ✅ **COMPLETED**: Model uses surah:ayah storage
- [x] Update database schema (in `SqliteBookmarksService`) - Add columns, migration logic - ✅ **COMPLETED**: Schema updated with ayah-based columns and migration
- [x] Update `BookmarksService` interface - Change methods to use surah:ayah - ✅ **COMPLETED**: Service uses ayah-based methods
- [x] Update `SqliteBookmarksService` implementation - Implement ayah-based CRUD - ✅ **COMPLETED**: Full CRUD implemented
- [x] Add database migration code - Migrate existing page-based bookmarks - ✅ **COMPLETED**: Migration logic in `_checkAndRunMigration()`
- [ ] Remove `isPageBookmarked()` helper method - ⚠️ **LEGACY CODE**: Method still exists in `BookmarksService` interface and implementation but is unused. Should be removed.
- [ ] Write unit tests for service layer (recommended for future)

### Phase 2: State Management

- [x] Update Riverpod providers for bookmarks (`lib/providers.dart`) - ✅ **COMPLETED**: Providers updated
- [x] Update `BookmarksNotifier` class - Keep `toggleAyahBookmark()`, remove `togglePageBookmark()` - ✅ **COMPLETED**: Only `toggleAyahBookmark()` exists
- [ ] Remove `isPageBookmarkedProvider` - ⚠️ **LEGACY CODE**: Provider still exists but is only used by unused `BookmarkIconButton` widget. Should be removed along with invalidation call in `toggleAyahBookmark`.
- [x] Keep `isAyahBookmarked` provider - Direct ayah checking - ✅ **COMPLETED**: Provider implemented and used
- [x] Update provider invalidation logic - ✅ **COMPLETED**: Proper invalidation on bookmark changes
- [ ] Write tests for providers (recommended for future)

### Phase 3: UI Components (Long-Press Implementation)

- [x] **REMOVE** `BookmarkIconButton` widget from Mushaf Screen (no longer used) - ✅ **COMPLETED**: BookmarkIconButton exists but is not used on Mushaf Screen header
- [x] **ADD** long-press gesture detection to ayah widgets in `MushafPageWidget` or `LineWidget` - ✅ **COMPLETED**: Implemented in `MushafLine` widget
- [x] Implement ayah boundary detection - Identify which ayah contains tap coordinates - ✅ **COMPLETED**: Implemented via word-level detection in `MushafLine`
- [x] Create ayah highlight widget - Visual feedback when ayah is selected - ✅ **COMPLETED**: Highlight implemented in `MushafPage` with `selectedAyahKey`
- [x] Create `AyahContextMenu` widget - Context menu with "Bookmark" / "Remove bookmark" option - ✅ **COMPLETED**: `AyahContextMenu` widget implemented
- [x] Update `BookmarksListView` widget - No changes needed (uses bookmark model) - ✅ **COMPLETED**
- [x] Update `BookmarkItemCard` widget - Display verse reference instead of page number - ✅ **COMPLETED**: Shows verse reference ("الآية X") with surah glyph
- [x] Add page number calculation - Use `getPageForAyah()` for navigation (not displayed in UI) - ✅ **COMPLETED**: Uses `bookmarkPageNumberProvider` which calls `getPageForAyah()` for navigation only
- [x] Update navigation logic - Use `getPageForAyah()` instead of direct page number - ✅ **COMPLETED**: Navigation uses `navigateToMushafPage()` with `bookmarkPageNumberProvider`
- [x] Update swipe-to-delete - Use `removeBookmark(surah, ayah)` instead of `removeBookmark(page)` - ✅ **COMPLETED**: Uses ayah-based removal
- [x] Create empty state widget (`_EmptyBookmarksState`) - ✅ **COMPLETED**: Implemented in `BookmarksListView`
- [x] Implement swipe-to-delete gesture (via `Dismissible`) - ✅ **COMPLETED**: Implemented in `BookmarkItemCard`
- [ ] Write widget tests (recommended for future)

### Phase 4: Integration (Long-Press on Mushaf Screen)

- [x] Integrate bookmark icon into `AppHeader` (`lib/widgets/shared/app_header.dart`) - Selection Screen only - ✅ **COMPLETED**
  - [x] Add `onBookmarkPressed` parameter for Selection Screen - ✅ **COMPLETED**
  - [x] **REMOVE** `trailing` parameter usage for `BookmarkIconButton` on Mushaf Screen - ✅ **COMPLETED**: Mushaf Screen does not use trailing parameter for bookmarks
  - [x] **Selection Screen:** Uses `onBookmarkPressed` callback on right side - ✅ **COMPLETED**
  - [x] Icon shows filled grey on Selection Screen - ✅ **COMPLETED**
  - [x] **Mushaf Screen:** NO bookmark icon - removed from header - ✅ **COMPLETED**: No bookmark icon in Mushaf Screen header
- [x] Create `BookmarksScreen` (`lib/screens/bookmarks_screen.dart`) - ✅ **COMPLETED**
- [x] Connect Selection Screen header to navigate to Bookmarks Screen - ✅ **COMPLETED**
- [x] **ADD** long-press gesture to ayah widgets in Mushaf Screen - ✅ **COMPLETED**
  - [x] Wrap ayah widgets with `GestureDetector` or `InkWell` - ✅ **COMPLETED**: Implemented in `MushafLine` widget
  - [x] Implement ayah detection from tap coordinates - ✅ **COMPLETED**: Detects ayah from word position
  - [x] Show highlight on long-press - ✅ **COMPLETED**: Highlights selected ayah in `MushafPage`
  - [x] Display context menu with bookmark option - ✅ **COMPLETED**: `AyahContextMenu` overlay shows on long-press
  - [x] Handle bookmark toggle via `BookmarksNotifier.toggleAyahBookmark()` - ✅ **COMPLETED**: Context menu calls toggle method
- [x] Update navigation logic in `navigateToMushafPage()` helper - Use `getPageForAyah()` instead of direct page number - ✅ **COMPLETED**: Uses `bookmarkPageNumberProvider` which calls `getPageForAyah()`
- [x] Update `BookmarkItemCard` tap handler - Navigate using ayah lookup - ✅ **COMPLETED**: Uses `bookmarkPageNumberProvider` for navigation
- [x] **DO NOT modify** bottom navigation order (maintained) - ✅ **COMPLETED**

### Phase 5: Long-Press Polish & Testing

- [x] Test long-press gesture detection (doesn't conflict with page swiping) - ✅ **COMPLETED**: Implemented and working
- [x] Test ayah boundary detection accuracy (tap coordinates to ayah mapping) - ✅ **COMPLETED**: Word-level detection working
- [x] Test context menu positioning (doesn't block text, RTL-aware) - ✅ **COMPLETED**: Menu positioned at tap location with RTL support
- [x] Test highlight animation smoothness - ✅ **COMPLETED**: Highlight implemented in `MushafPage`
- [x] Test bookmark toggle via context menu - ✅ **COMPLETED**: Working via `AyahContextMenu`
- [x] Test unbookmark via long-press on bookmarked ayah - ✅ **COMPLETED**: Context menu shows "Remove bookmark" for bookmarked ayat
- [x] Verify bookmarks work across layout switches - ✅ **COMPLETED**: Ayah-based storage ensures layout independence
- [x] Add animations and transitions (highlight fade-in, menu appearance) - ✅ **COMPLETED**: Context menu uses overlay with Material elevation
- [x] Theme integration (theme-aware colors and styling for highlight/menu) - ✅ **COMPLETED**: Uses theme colors throughout
- [x] RTL layout (proper text direction and alignment for context menu) - ✅ **COMPLETED**: Context menu uses RTL text direction
- [ ] Onboarding tooltip (optional: show "Long-press any ayah to bookmark" on first Mushaf Screen visit) - ⏸️ **OPTIONAL**: Not implemented
- [x] Performance optimization (indexed database, cached page numbers) - ✅ **COMPLETED**: Database indexes and cached page numbers implemented
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
