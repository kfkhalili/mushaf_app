# Bookmarks Feature Specification

**Version:** 2.0 (As Implemented)
**Date:** January 2025
**Status:** ✅ Implemented and Complete
**Priority:** High (Quarter 1)

**Note:** This specification now reflects the actual implementation of the bookmarks feature as it exists in the codebase.

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

#### 3.2.2 Bookmarks Screen

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
  → Tap filled grey bookmark icon in header (RIGHT side, separated from Settings/Search)
  → Navigate to Bookmarks Screen (full screen)
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

**Riverpod Providers (Actual Implementation):**

```dart
// Provider for bookmarks service
@Riverpod(keepAlive: true)
BookmarksService bookmarksService(Ref ref) {
  return SqliteBookmarksService();
}

// Provider for checking if specific page is bookmarked
@riverpod
Future<bool> isPageBookmarked(Ref ref, int pageNumber) async {
  final service = ref.watch(bookmarksServiceProvider);
  return service.isBookmarked(pageNumber);
}

// Notifier for bookmark operations (class name: BookmarksNotifier)
@Riverpod(keepAlive: true)
class BookmarksNotifier extends _$BookmarksNotifier {
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

**Usage:**
- Access list: `ref.watch(bookmarksProvider)` (auto-generated from `BookmarksNotifier`)
- Toggle bookmark: `ref.read(bookmarksProvider.notifier).toggleBookmark(pageNumber)`
- Remove bookmark: `ref.read(bookmarksProvider.notifier).removeBookmark(pageNumber)`

---

## 6. UI Components

### 6.1 Header Bookmark Icon

**Location:** `lib/widgets/shared/app_header.dart`

**Actual Implementation:**

The `AppHeader` widget supports bookmarks in two ways:
1. **Via `trailing` parameter:** For Mushaf Screen (dynamic bookmark state using `BookmarkIconButton`)
2. **Via `onBookmarkPressed` callback:** For Selection Screen (navigation to BookmarksScreen)

**AppHeader Parameters:**
- `onBookmarkPressed?: VoidCallback` - Callback for Selection Screen navigation
- `trailing?: Widget` - Custom widget for Mushaf Screen (BookmarkIconButton)
- Conditional rendering: Icon shown when `onBookmarkPressed != null && trailing == null`

**Selection Screen Implementation:**
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

**Mushaf Screen Implementation:**
```dart
AppHeader(
  title: asyncPageData.when(...),
  trailing: BookmarkIconButton(pageNumber: currentPageNumber),
)
```

**Selection Screen Icon Details:**
- Position: **Right side** of header Row (after title Expanded, before back button if present)
- Icon: Always filled `Icons.bookmark`
- Size: `kAppHeaderIconSize` (24.0)
- Color: Grey (`Colors.grey.shade400` dark / `Colors.grey.shade600` light) - matches Settings/Search
- Tooltip: "العلامات المرجعية"
- Behavior: Navigates to `BookmarksScreen` on tap

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

**Content Display:**
- **Line 1:** Bookmark icon (20px) + Page number (22px, Eastern Arabic numerals)
- **Line 2:** Surah name glyph (28px, surah font) or loading indicator
- **Line 3:** Relative date (15px, right-aligned, muted color)

**Data Source:**
- Uses `pageDataProvider(bookmark.pageNumber)` to fetch page data for surah display
- Shows `LinearProgressIndicator` while loading surah name
- Date formatted using `formatRelativeDate()` helper function (`lib/utils/helpers.dart`)

**Swipe-to-Delete:**
- Uses `Dismissible` widget with `DismissDirection.endToStart` (swipe right in RTL)
- Background: Red container with `Icons.delete_outline` on left side
- On dismiss: Calls `removeBookmark()` and shows Arabic snackbar "تم حذف العلامة المرجعية"
- No confirmation dialog (direct deletion)

### 6.5 Bookmark Icon Button

**File:** `lib/widgets/bookmark_icon_button.dart`

**Actual Implementation:**

**Widget:** `BookmarkIconButton` extends `ConsumerStatefulWidget`

**Features:**
- Dynamic icon state based on bookmark status (outlined/filled)
- Scale animation on toggle (1.0 → 1.2 → 1.0)
- Watches `isPageBookmarkedProvider(pageNumber)` for reactive state
- Handles toggle via `BookmarksNotifier.toggleBookmark()`
- Loading state: Shows outlined icon, disabled
- Error state: Shows outlined icon, still clickable

**Implementation Details:**
```dart
class BookmarkIconButton extends ConsumerStatefulWidget {
  final int pageNumber;

  // Uses SingleTickerProviderStateMixin for animation
  AnimationController _animationController;
  Animation<double> _scaleAnimation; // 1.0 to 1.2

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncIsBookmarked = ref.watch(isPageBookmarkedProvider(pageNumber));

    return asyncIsBookmarked.when(
      data: (isBookmarked) {
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                color: isBookmarked ? primaryColor : greyColor,
                onPressed: _handleTap,
              ),
            );
          },
        );
      },
      loading: () => IconButton(icon: outlined icon, onPressed: null),
      error: (_, __) => IconButton(icon: outlined icon, onPressed: _handleTap),
    );
  }
}
```

**Animation:**
- Duration: 200ms
- Curve: `Curves.easeInOut`
- Trigger: On tap (forward then reverse)

**Icon States:**
- Not bookmarked: `Icons.bookmark_border` (grey)
- Bookmarked: `Icons.bookmark` (primary color)
- Tooltip: "حفظ الصفحة" / "إزالة العلامة المرجعية"
- Size: `kAppHeaderIconSize` (24.0)

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

**Actual Implementation:**

**Integration:**
1. Uses `BookmarkIconButton` widget via `AppHeader.trailing` parameter
2. Passes `currentPageNumber` from `ref.watch(currentPageProvider)`
3. No manual provider watching needed (handled by `BookmarkIconButton` internally)
4. No manual invalidation needed (handled by `BookmarksNotifier`)

**Code:**
```dart
AppHeader(
  title: asyncPageData.when(...),
  trailing: BookmarkIconButton(pageNumber: currentPageNumber),
)
```

**BookmarkIconButton** handles:
- Watching `isPageBookmarkedProvider(pageNumber)`
- Displaying correct icon state
- Handling tap to toggle bookmark
- Animating icon on toggle
- Provider invalidation after toggle

### 7.3 App Header (Both Screens)

**File:** `lib/widgets/shared/app_header.dart`

**Actual Implementation:**

**Header Structure:**
```
Row([
  // Left: Settings/Search icons
  Row([Settings, Search]),
  // Center: Title (Expanded)
  Expanded(title),
  // Right: Bookmark icon (Selection) OR trailing widget (Mushaf)
  if (onBookmarkPressed != null && trailing == null) BookmarkIcon,
  if (trailing != null) trailing,
  // Back button (if enabled)
  if (showBackButton) BackButton,
])
```

**Mushaf Screen:**
- Uses `trailing` parameter with `BookmarkIconButton` widget
- Icon appears on right side (after title)
- Dynamic state (outlined/filled) handled by widget
- Color changes: Grey (outlined) → Primary (filled)

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

**Actual Implementation:**

**Approach:** Separate SQLite database file (`bookmarks.db`) created in app documents directory

**Location:** `lib/services/bookmarks_service.dart`

**Initialization:**
- Database created lazily on first access via `_ensureInitialized()`
- Version: 1 (defined in `openDatabase` call)
- Table and indexes created in `onCreate` callback
- No migration needed (new feature, separate database file)

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

✅ User can bookmark any page (1-604) by tapping header icon in Mushaf Screen
✅ Bookmark icon shows correct state (filled/outlined) in Mushaf Screen
✅ Bookmark icon always visible (filled grey) in Selection Screen header
✅ User can access bookmarks by tapping header icon in Selection Screen
✅ User can view all bookmarks in dedicated full-screen list
✅ User can navigate to bookmarked page from list
✅ User can remove bookmark via toggle (Mushaf) or swipe-to-delete (list)
✅ Bookmarks persist across app restarts
✅ Bookmark state updates immediately when toggled
✅ No duplicate bookmarks (same page)
✅ Empty state displays when no bookmarks exist
✅ Bookmarks list uses proper RTL layout with right-aligned content

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

**Status:** ✅ All phases completed and implemented

### Phase 1: Database & Service Layer

- [x] Create `Bookmark` model class (`lib/models.dart`)
- [x] Create database schema (in `SqliteBookmarksService`)
- [x] Implement `BookmarksService` interface
- [x] Implement `SqliteBookmarksService` (`lib/services/bookmarks_service.dart`)
- [x] Add database initialization code (`_ensureInitialized()`)
- [ ] Write unit tests for service layer (recommended for future)

### Phase 2: State Management

- [x] Create Riverpod providers for bookmarks (`lib/providers.dart`)
- [x] Create `BookmarksNotifier` class (not `Bookmarks`)
- [x] Implement `isPageBookmarked` provider
- [ ] Write tests for providers (recommended for future)

### Phase 3: UI Components

- [x] Create `BookmarkIconButton` widget (`lib/widgets/bookmark_icon_button.dart`)
- [x] Create `BookmarksListView` widget (`lib/widgets/bookmarks_list_view.dart`)
- [x] Create `BookmarkItemCard` widget (`lib/widgets/bookmark_item_card.dart`)
- [x] Create empty state widget (`_EmptyBookmarksState`)
- [x] Implement swipe-to-delete gesture (via `Dismissible`)
- [ ] Write widget tests (recommended for future)

### Phase 4: Integration

- [x] Integrate bookmark icon into `AppHeader` (`lib/widgets/shared/app_header.dart`)
  - [x] Add `onBookmarkPressed` parameter for Selection Screen
  - [x] **Mushaf Screen:** Uses `trailing` parameter with `BookmarkIconButton`
  - [x] **Selection Screen:** Uses `onBookmarkPressed` callback on right side
  - [x] Icon separated from Settings/Search (on opposite side of header)
  - [x] Icon shows filled grey on Selection Screen
  - [x] Icon shows dynamic state (outlined/filled) on Mushaf Screen
- [x] Create `BookmarksScreen` (`lib/screens/bookmarks_screen.dart`)
- [x] Connect Selection Screen header to navigate to Bookmarks Screen
- [x] Connect Mushaf Screen to bookmark state via `BookmarkIconButton`
- [x] Update navigation flows
- [x] **DO NOT modify** bottom navigation order (maintained)

### Phase 5: Polish & Testing

- [x] Add animations and transitions (scale animation on toggle)
- [x] Theme integration (theme-aware colors and styling)
- [x] RTL layout (proper text direction and alignment)
- [x] Performance optimization (indexed database, lazy loading)
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
