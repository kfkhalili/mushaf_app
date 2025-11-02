# Reading Progress Feature Specification

**Version:** 1.0
**Date:** January 2025
**Status:** Ready for Implementation
**Priority:** High (Quarter 1)

---

## 1. Overview

### 1.1 Purpose

The Reading Progress feature tracks and visualizes users' reading activity in the Mushaf app. It provides feedback on reading habits, motivates continued engagement, and helps users build consistent reading routines.

### 1.2 Goals

- **Engagement:** Motivate users to read regularly by showing progress
- **Habit Building:** Encourage consistent daily reading through visual feedback
- **Insight:** Provide users with awareness of their reading patterns
- **Motivation:** Celebrate milestones and reading achievements
- **Simplicity:** Keep implementation simple and lightweight

### 1.3 Success Metrics

- Daily active users increase (target: 15% increase)
- Average session length increase (target: 20% increase)
- Reading streak adoption rate (target: 40% of active users maintain streaks)
- Return rate (users returning within 7 days)
- Pages read per session average

---

## 2. User Stories

### Primary Stories

1. **As a user**, I want to see how many pages I've read today, so I know my daily progress
2. **As a user**, I want to see my reading progress over time, so I can track my consistency
3. **As a user**, I want to see a visual indicator of my overall progress, so I feel motivated
4. **As a user**, I want to see my reading statistics, so I understand my reading patterns
5. **As a user**, I want to see if I'm maintaining a reading streak, so I'm motivated to read daily

### Secondary Stories

6. **As a user**, I want to see which days I read this week, so I can identify patterns
7. **As a user**, I want to see my total pages read, so I appreciate my cumulative effort
8. **As a user**, I want progress to update automatically as I read, so it's effortless

---

## 3. Feature Requirements

### 3.1 Core Functionality

#### 3.1.1 Progress Tracking

- **Trigger:** Automatic tracking when user navigates pages in Mushaf Screen
- **What to Track:**
  - Pages read per session
  - Pages read per day
  - Pages read per week
  - Pages read per month
  - Total pages read (all-time)
  - Reading dates (for streak calculation)
  - Session duration (optional, future enhancement)
- **Storage:** Persistent storage using SQLite (similar to bookmarks pattern)

#### 3.1.2 Progress Calculation

- **Page Count Logic:**
  - Record page view when user navigates to a new page (page change event)
  - Record immediately in `onPageChanged` callback (no delay)
  - Use `COUNT(DISTINCT page_number)` for unique page counts (not total views)
  - Count unique pages per day: same page read twice = 1 unique page for that day
  - Count unique pages all-time: same page read multiple days = 1 unique page total
- **Sessions vs Pages:**
  - Sessions: Total page views (count all records)
  - Pages: Unique pages (count distinct `page_number`)
- **Daily Progress:**
  - Reset at midnight (local timezone)
  - Track pages read today
  - Show simple count: "15 pages today"
- **Overall Progress:**
  - Total unique pages read (all-time)
  - Percentage: "150/604 pages (25%)"
  - Visual progress bar or circular indicator

#### 3.1.3 Reading Streak

- **Definition:** Consecutive days with at least 1 page read
- **Calculation:** Count consecutive days from today backwards
- **Display:** "3 day streak" or "Streak: 3 days 🔥"
- **Reset:** Breaks if user doesn't read for a day
- **Visual:** Simple number with optional flame icon for active streaks

#### 3.1.4 Statistics Summary

- **Today:**
  - Pages read today
  - Sessions today
- **This Week:**
  - Total pages this week
  - Days read this week (e.g., "5 of 7 days")
  - Average pages per day
- **This Month:**
  - Total pages this month
  - Days read this month
  - Average pages per day
- **All-Time:**
  - Total unique pages read
  - Total reading days
  - Longest streak
  - Current streak

### 3.2 UI/UX Requirements

#### 3.2.1 Progress Display Locations

**Option 1: Header Widget (Primary)**

- Small progress indicator in Mushaf Screen header
- Shows today's progress: "15 pages today"
- Tappable to open detailed statistics screen
- Minimal visual footprint

**Option 2: Settings Screen Section**

- Dedicated "Reading Progress" section in Settings
- Shows summary statistics
- Link to detailed statistics screen

**Option 3: Selection Screen Widget**

- Optional progress widget on Selection Screen
- Shows today's count or current streak
- Less prominent, doesn't clutter navigation

**Recommended Approach:** Start with Settings Screen section (simplest), add header widget later if needed.

#### 3.2.2 Statistics Screen

**Access Point:**

- Settings Screen → "Reading Progress" section → Tap to open Statistics Screen
- Optional: Direct navigation from header progress indicator

**Screen Layout (RTL):**

```
┌─────────────────────────────────────────┐
│ [Header: Statistics + Back]             │
├─────────────────────────────────────────┤
│                                         │
│         📊 إحصائيات القراءة            │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  التقدم الإجمالي                   │ │
│  │  150 / 604 صفحة (25%)              │ │
│  │  ████████░░░░░░░░░░░░░░░            │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  اليوم                              │ │
│  │  15 صفحة                             │ │
│  │  3 جلسات                             │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  هذا الأسبوع                       │ │
│  │  85 صفحة                            │ │
│  │  5 من 7 أيام                        │ │
│  │  متوسط: 12 صفحة/يوم                │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  هذا الشهر                         │ │
│  │  320 صفحة                           │ │
│  │  18 يوم                             │ │
│  │  متوسط: 18 صفحة/يوم                │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  🔥 السلسلة                        │ │
│  │  3 أيام                             │ │
│  │  حافظ على السلسلة!                 │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  إجمالي                            │ │
│  │  150 صفحة فريدة                    │ │
│  │  45 يوم قراءة                       │ │
│  │  أطول سلسلة: 7 أيام                │ │
│  └───────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

**Card Design:**

- Rounded cards with subtle borders
- Clear section headers
- Large, readable numbers
- Progress bars for percentage displays
- RTL text alignment
- Theme-aware colors

#### 3.2.3 Progress Indicators

**Overall Progress Bar:**

- Horizontal progress bar showing: `pages_read / total_pages`
- Percentage display: "25%"
- Color: Primary theme color for filled portion
- Label: "150 / 604 صفحة"

**Daily Progress:**

- Simple count: "15 صفحات اليوم"
- Optional small progress bar for daily goal (future enhancement)

**Streak Indicator:**

- Number of consecutive days
- Fire icon (🔥) for active streaks (3+ days)
- Encouragement message: "حافظ على السلسلة!"
- Color: Orange/red when active

#### 3.2.4 Visual Design

**Colors (Theme-Aware):**

- Progress bars: Primary theme color
- Active streak: Orange/red accent
- Numbers: Primary text color
- Labels: Secondary text color
- Cards: Theme card color with subtle border

**Typography:**

- Section titles: 18px, bold
- Large numbers: 32px, bold (Eastern Arabic numerals)
- Labels: 14px, regular
- Descriptions: 13px, muted

**Spacing:**

- Card padding: 16px
- Card margin: 8px vertical, 16px horizontal
- Section spacing: 24px vertical

---

## 4. Data Model

### 4.1 Reading Session Model

```dart
@immutable
class ReadingSession {
  final int id; // Primary key (auto-increment)
  final DateTime sessionDate; // Date of reading session
  final int pageNumber; // Page that was read
  final DateTime timestamp; // Exact time page was viewed
  final int? durationSeconds; // Optional: How long page was viewed (future)

  const ReadingSession({
    required this.id,
    required this.sessionDate,
    required this.pageNumber,
    required this.timestamp,
    this.durationSeconds,
  });

  ReadingSession copyWith({
    int? id,
    DateTime? sessionDate,
    int? pageNumber,
    DateTime? timestamp,
    int? durationSeconds,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      sessionDate: sessionDate ?? this.sessionDate,
      pageNumber: pageNumber ?? this.pageNumber,
      timestamp: timestamp ?? this.timestamp,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          pageNumber == other.pageNumber &&
          sessionDate == other.sessionDate;

  @override
  int get hashCode => Object.hash(id, pageNumber, sessionDate);
}
```

### 4.2 Reading Statistics Model

```dart
@immutable
class ReadingStatistics {
  final int totalPagesRead; // Unique pages read (all-time)
  final int totalReadingDays; // Days with at least 1 page read
  final int currentStreak; // Current consecutive days streak
  final int longestStreak; // Longest streak ever achieved
  final int pagesToday; // Pages read today
  final int pagesThisWeek; // Pages read this week
  final int pagesThisMonth; // Pages read this month
  final int daysThisWeek; // Days read this week (1-7)
  final int daysThisMonth; // Days read this month
  final double averagePagesPerDay; // Average pages per reading day

  const ReadingStatistics({
    required this.totalPagesRead,
    required this.totalReadingDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.pagesToday,
    required this.pagesThisWeek,
    required this.pagesThisMonth,
    required this.daysThisWeek,
    required this.daysThisMonth,
    required this.averagePagesPerDay,
  });

  double get overallProgress => totalPagesRead / totalPages; // 0.0 to 1.0
  int get overallProgressPercent => (overallProgress * 100).round();
}
```

### 4.3 Database Schema

**Table: `reading_sessions`**

| Column             | Type    | Constraints               | Description                |
| ------------------ | ------- | ------------------------- | -------------------------- |
| `id`               | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique identifier          |
| `session_date`     | TEXT    | NOT NULL                  | ISO 8601 date (YYYY-MM-DD) |
| `page_number`      | INTEGER | NOT NULL                  | Page number (1-604)        |
| `timestamp`        | TEXT    | NOT NULL                  | ISO 8601 timestamp         |
| `duration_seconds` | INTEGER | NULL                      | Optional: viewing duration |

**Indexes:**

- `CREATE INDEX idx_reading_sessions_date ON reading_sessions(session_date DESC);`
- `CREATE INDEX idx_reading_sessions_page ON reading_sessions(page_number);`
- `CREATE INDEX idx_reading_sessions_timestamp ON reading_sessions(timestamp DESC);`

**SQL Creation:**

```sql
CREATE TABLE IF NOT EXISTS reading_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_date TEXT NOT NULL,
  page_number INTEGER NOT NULL,
  timestamp TEXT NOT NULL,
  duration_seconds INTEGER
);

CREATE INDEX IF NOT EXISTS idx_reading_sessions_date
  ON reading_sessions(session_date DESC);

CREATE INDEX IF NOT EXISTS idx_reading_sessions_page
  ON reading_sessions(page_number);

CREATE INDEX IF NOT EXISTS idx_reading_sessions_timestamp
  ON reading_sessions(timestamp DESC);
```

**Data Aggregation Notes:**

- Statistics calculated on-demand from `reading_sessions` table
- No separate statistics table needed (calculated queries)
- For performance, consider caching statistics (refresh every session)

---

## 5. Service Layer

### 5.1 Reading Progress Service

**File:** `lib/services/reading_progress_service.dart`

**Responsibilities:**

- Track page views as reading sessions
- Calculate statistics from session data
- Calculate reading streaks
- Query reading history

**Interface:**

```dart
abstract class ReadingProgressService {
  Future<void> recordPageView(int pageNumber);
  Future<ReadingStatistics> getStatistics();
  Future<int> getPagesReadToday();
  Future<int> getCurrentStreak();
  Future<List<int>> getPagesReadByDate(DateTime date);
  Future<Map<DateTime, int>> getWeeklyProgress(); // Date -> pages count
  Future<Map<DateTime, int>> getMonthlyProgress();
  Future<void> clearAllData(); // For privacy/reset
}
```

**Implementation Details (Following Bookmarks Pattern):**

- **Separate SQLite Database:** Uses dedicated `reading_progress.db` file (same pattern as `bookmarks.db`)
- **Database Location:** `{documentsDirectory}/reading_progress.db`
- **Database Version:** 1 (created in `onCreate` callback)
- **Initialization:** Lazy initialization via `_ensureInitialized()` method (called before each operation)
- **Database Connection:** Stored in `_db` field, checked for null before operations
- **Validation:** Page numbers validated to be between 1 and `totalPages` (604) in `recordPageView()`
- **Error Handling:** Exceptions caught and re-thrown with descriptive messages
- **Dependencies:**
  - `sqflite` - Database operations
  - `path` - Path joining utilities
  - `path_provider` - App documents directory access
- **Indexes:**
  - `idx_reading_sessions_date` on `session_date DESC`
  - `idx_reading_sessions_page` on `page_number`
  - `idx_reading_sessions_timestamp` on `timestamp DESC`
- **Table/Column Names:** Uses `DbConstants` class:
  - `DbConstants.readingSessionsTable` = 'reading_sessions'
  - `DbConstants.sessionDateCol` = 'session_date'
  - `DbConstants.pageNumberCol` = 'page_number' (already defined)
  - `DbConstants.timestampCol` = 'timestamp'
  - `DbConstants.durationSecondsCol` = 'duration_seconds'
- **Page View Recording:**
  - Called when user navigates to a new page in Mushaf Screen
  - Records: date (YYYY-MM-DD string), page number, timestamp (ISO 8601 string)
  - Does NOT deduplicate (records all page views for accurate session tracking)
  - Use `COUNT(DISTINCT page_number)` for unique page counts
- **Statistics Calculation:**
  - Calculate from `reading_sessions` table using SQL aggregations
  - Cache results for performance (invalidate on new page view)
  - Use SQL `COUNT(DISTINCT)` for unique page counts

**Key Methods:**

```dart
class SqliteReadingProgressService implements ReadingProgressService {
  Database? _db;
  bool _initialized = false;
  ReadingStatistics? _cachedStatistics;

  Future<void> _ensureInitialized() async {
    if (_initialized && _db != null) return;

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, 'reading_progress.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DbConstants.readingSessionsTable} (
            ${DbConstants.idCol} INTEGER PRIMARY KEY AUTOINCREMENT,
            ${DbConstants.sessionDateCol} TEXT NOT NULL,
            ${DbConstants.pageNumberCol} INTEGER NOT NULL,
            ${DbConstants.timestampCol} TEXT NOT NULL,
            ${DbConstants.durationSecondsCol} INTEGER
          )
        ''');

        // Create indexes
        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_reading_sessions_date
          ON ${DbConstants.readingSessionsTable}(${DbConstants.sessionDateCol} DESC)
        ''');
        // ... other indexes
      },
    );

    _initialized = true;
  }

  // Record a page view
  @override
  Future<void> recordPageView(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > totalPages) {
      throw ArgumentError('Page number must be between 1 and $totalPages');
    }

    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    final now = DateTime.now();
    final sessionDate = DateTime(now.year, now.month, now.day);

    try {
      await _db!.insert(
        DbConstants.readingSessionsTable,
        {
          DbConstants.sessionDateCol: sessionDate.toIso8601String().split('T')[0],
          DbConstants.pageNumberCol: pageNumber,
          DbConstants.timestampCol: now.toIso8601String(),
        },
      );

      // Invalidate statistics cache
      _cachedStatistics = null;
    } catch (e) {
      throw Exception('Failed to record page view: $e');
    }
  }

  // Calculate statistics
  @override
  Future<ReadingStatistics> getStatistics() async {
    await _ensureInitialized();
    if (_db == null) throw StateError('Database not initialized');

    // Check cache first
    if (_cachedStatistics != null) return _cachedStatistics!;

    try {
      // Calculate from database using SQL aggregations
      final totalPagesRead = await _getUniquePagesCount();
      final pagesToday = await _getPagesToday();
      final pagesThisWeek = await _getPagesThisWeek();
      final pagesThisMonth = await _getPagesThisMonth();
      final currentStreak = await _calculateCurrentStreak();
      final longestStreak = await _calculateLongestStreak();
      // ... calculate other fields

      _cachedStatistics = ReadingStatistics(...);
      return _cachedStatistics!;
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }
}
```

### 5.2 Provider Integration

**File:** `lib/providers.dart`

**Riverpod Providers:**

```dart
// Provider for reading progress service
@Riverpod(keepAlive: true)
ReadingProgressService readingProgressService(Ref ref) {
  return SqliteReadingProgressService();
}

// Provider for reading statistics
@riverpod
Future<ReadingStatistics> readingStatistics(Ref ref) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getStatistics();
}

// Provider for pages read today
@riverpod
Future<int> pagesReadToday(Ref ref) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getPagesReadToday();
}

// Provider for current streak
@riverpod
Future<int> currentStreak(Ref ref) async {
  final service = ref.watch(readingProgressServiceProvider);
  return service.getCurrentStreak();
}
```

**Usage:**

- Watch statistics: `ref.watch(readingStatisticsProvider)`
- Record page view: `ref.read(readingProgressServiceProvider).recordPageView(pageNumber)`
- Refresh statistics: `ref.invalidate(readingStatisticsProvider)`

---

## 6. UI Components

### 6.1 Statistics Screen

**File:** `lib/screens/statistics_screen.dart` (new file)

**Actual Implementation Pattern (Following BookmarksScreen):**

- Full screen dedicated to reading statistics
- Uses `AppHeader` with `showBackButton: true`
- Empty title string (or "إحصائيات القراءة")
- Wraps `StatisticsListView` in `Directionality(textDirection: TextDirection.rtl)`
- Contains `StatisticsListView` widget

**Structure:**

```dart
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'إحصائيات القراءة',
              showBackButton: true,
            ),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: StatisticsListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6.2 Statistics List View

**File:** `lib/widgets/statistics_list_view.dart`

**Features (Following BookmarksListView Pattern):**

- List of statistic cards using `ListView.builder` or `ListView`
- Loading state (CircularProgressIndicator)
- Error state handling with user-friendly Arabic message
- Empty state widget (if no reading history)
- RTL text direction set at parent level (`StatisticsScreen`)

**Implementation:**

```dart
ConsumerWidget(
  build: (context, ref) {
    final statsAsync = ref.watch(readingStatisticsProvider);
    return statsAsync.when(
      data: (stats) {
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            OverallProgressCard(stats: stats),
            TodayCard(stats: stats),
            ThisWeekCard(stats: stats),
            ThisMonthCard(stats: stats),
            StreakCard(stats: stats),
            AllTimeCard(stats: stats),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(...), // Error UI
    );
  },
)
```

**Cards:**

1. Overall Progress Card (progress bar + percentage)
2. Today Card (pages + sessions)
3. This Week Card (pages + days + average)
4. This Month Card (pages + days + average)
5. Streak Card (current streak with icon)
6. All-Time Card (total pages + days + longest streak)

**Empty State:**

- Icon: `Icons.bar_chart` (64px, muted color)
- Title: "لا توجد إحصائيات بعد" (20px, bold)
- Description: "ابدأ القراءة لتتبع تقدمك!" (16px)

### 6.3 Progress Card Widget

**File:** `lib/widgets/progress_card.dart`

**Features:**

- Reusable card for statistics display (similar to `BookmarkItemCard` pattern)
- Supports different card types (today, week, month, streak, etc.)
- RTL layout using `textDirection: TextDirection.rtl`
- Theme-aware styling

**Card Types:**

- **Overall Progress Card:** Large progress bar + percentage display
- **Today Card:** Title + large number (pages) + subtitle (sessions)
- **Week/Month Card:** Title + pages count + days count + average
- **Streak Card:** Special styling with fire icon (🔥) + encouragement message
- **All-Time Card:** Title + multiple statistics (total pages, days, longest streak)

**RTL Layout Pattern (Following BookmarkItemCard):**

- Card wrapped in `Directionality(textDirection: TextDirection.rtl)` at parent level
- Content uses `CrossAxisAlignment.start` (which is RTL natural start = right side visually)
- Text widgets use `TextAlign.left` (which aligns to RTL start = right side visually)
- Numbers displayed in Eastern Arabic numerals using `convertToEasternArabicNumerals()` helper
- Large numbers use bold font (similar to bookmark page number styling)

### 6.4 Progress Indicator Widget (Future)

**File:** `lib/widgets/progress_indicator_widget.dart`

**Features:**

- Small widget for header display
- Shows today's pages count
- Tappable to open statistics screen
- Minimal visual footprint

---

## 7. Integration Points

### 7.1 Mushaf Screen

**File:** `lib/screens/mushaf_screen.dart`

**Changes Required:**

1. Record page views when user navigates pages
   - Call `readingProgressService.recordPageView(pageNumber)` on page change
   - Trigger in `onPageChanged` callback of PageView
2. Optional: Show small progress indicator in header
   - Display "X pages today" or current streak
   - Link to statistics screen

**Implementation (Following Mushaf Screen Pattern):**

```dart
onPageChanged: (index) {
  final int newPageNumber = index + 1;
  // WHY: Update the global state provider.
  ref.read(currentPageProvider.notifier).setPage(newPageNumber);
  _savePageToPrefs(newPageNumber);

  // Record reading progress (fire-and-forget, no await needed)
  ref.read(readingProgressServiceProvider).recordPageView(newPageNumber);

  // Optional: Invalidate statistics to refresh (only if statistics screen is open)
  // ref.invalidate(readingStatisticsProvider);
},
```

**Integration Notes:**

- Record page view in `onPageChanged` callback (non-blocking)
- No need to await the database operation (fire-and-forget)
- Statistics will refresh automatically when Statistics Screen is opened (recalculates from DB)
- Don't invalidate providers unnecessarily (only invalidate if Statistics Screen is currently visible)

### 7.2 Settings Screen

**File:** `lib/screens/settings_screen.dart`

**Changes Required:**

1. Add "Reading Progress" section
   - Display summary: "X pages today" or "X day streak"
   - Tappable to navigate to Statistics Screen
2. Optional: Show progress percentage in section
   - Small progress bar showing overall progress

**Implementation (Following Settings Screen Pattern):**

```dart
// Add new Card section for Reading Progress
Card(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات القراءة',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('إحصائيات القراءة'),
          subtitle: Consumer(
            builder: (context, ref, _) {
              final statsAsync = ref.watch(readingStatisticsProvider);
              return statsAsync.when(
                data: (stats) => Text(
                  '${convertToEasternArabicNumerals(stats.pagesToday.toString())} صفحات اليوم',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
                loading: () => const Text('جارٍ التحميل...'),
                error: (_, __) => const Text('--'),
              );
            },
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatisticsScreen()),
            );
          },
        ),
      ],
    ),
  ),
),
```

**Settings Screen Structure:**

- Add new Card section after existing Theme and About sections
- Follow same Card/Padding pattern as existing sections
- Use `Consumer` widget for reactive statistics display
- Use `ListTile` with leading icon, title, subtitle, and trailing chevron

### 7.3 Constants Update

**File:** `lib/constants.dart`

**Changes Required:**

Add to `DbConstants` class:

```dart
// --- Reading Progress Table ---
static const String readingSessionsTable = 'reading_sessions';
static const String sessionDateCol = 'session_date';
static const String timestampCol = 'timestamp';
static const String durationSecondsCol = 'duration_seconds';
```

---

## 8. Technical Implementation

### 8.1 Database Strategy

**Option 1: Separate Database (Recommended - Matches Bookmarks Pattern)**

- Create `reading_progress.db` similar to `bookmarks.db`
- Same pattern as existing bookmarks implementation
- Simpler migration and isolation
- Easier to clear/reset independently
- Consistent with existing codebase architecture

**Option 2: Extend Bookmarks Database**

- Add `reading_sessions` table to `bookmarks.db`
- Single database file
- Slightly more complex but fewer files
- Not recommended (breaks isolation pattern)

**Recommendation:** Use separate database (Option 1) to match existing bookmarks pattern and maintain consistency.

### 8.2 Statistics Calculation

**Caching Strategy:**

- Cache statistics in memory
- Invalidate cache when new page view recorded
- Refresh cache on statistics screen open
- Cache lifetime: Until next page view or app restart

**Query Optimization:**

- Use SQL aggregations (`COUNT`, `DISTINCT`, `GROUP BY`)
- Index on `session_date` for fast date queries
- Calculate streaks using SQL window functions or app logic

**Example Queries (Using DbConstants Pattern):**

```sql
-- Pages read today (using date string format)
SELECT COUNT(DISTINCT ${DbConstants.pageNumberCol})
FROM ${DbConstants.readingSessionsTable}
WHERE ${DbConstants.sessionDateCol} = date('now');

-- Total unique pages
SELECT COUNT(DISTINCT ${DbConstants.pageNumberCol})
FROM ${DbConstants.readingSessionsTable};

-- Pages this week
SELECT COUNT(DISTINCT ${DbConstants.pageNumberCol})
FROM ${DbConstants.readingSessionsTable}
WHERE ${DbConstants.sessionDateCol} >= date('now', '-7 days');

-- Days read this week (distinct dates)
SELECT COUNT(DISTINCT ${DbConstants.sessionDateCol})
FROM ${DbConstants.readingSessionsTable}
WHERE ${DbConstants.sessionDateCol} >= date('now', '-7 days');

-- Sessions today (total page views, not unique)
SELECT COUNT(*)
FROM ${DbConstants.readingSessionsTable}
WHERE ${DbConstants.sessionDateCol} = date('now');
```

**Date Format:**

- Store dates as ISO 8601 date strings (YYYY-MM-DD format)
- Use `DateTime.now().toIso8601String().split('T')[0]` for date string
- SQLite `date('now')` returns current date in YYYY-MM-DD format for comparison

### 8.3 Streak Calculation

**Algorithm:**

1. Start from today
2. Check if user read today (at least 1 page)
3. If yes, count backwards day by day
4. Stop when finding a day with 0 pages
5. Return consecutive days count

**Implementation:**

```dart
Future<int> calculateCurrentStreak() async {
  await _ensureInitialized();
  if (_db == null) throw StateError('Database not initialized');

  // Check today first - must have read today to have a streak
  final todayDateStr = DateTime.now().toIso8601String().split('T')[0];
  final todayResult = await _db!.query(
    DbConstants.readingSessionsTable,
    columns: [DbConstants.pageNumberCol],
    where: '${DbConstants.sessionDateCol} = ?',
    whereArgs: [todayDateStr],
    limit: 1,
  );

  if (todayResult.isEmpty) return 0; // No reading today = no streak

  // Count consecutive days backwards from today
  int streak = 0;
  DateTime checkDate = DateTime.now();

  while (true) {
    final dateStr = checkDate.toIso8601String().split('T')[0];
    final result = await _db!.query(
      DbConstants.readingSessionsTable,
      columns: [DbConstants.pageNumberCol],
      where: '${DbConstants.sessionDateCol} = ?',
      whereArgs: [dateStr],
      limit: 1,
    );

    if (result.isEmpty) break; // Found a day with no reading

    streak++;
    checkDate = checkDate.subtract(const Duration(days: 1));

    // Safety limit (prevent infinite loop)
    if (streak > 365) break;
  }

  return streak;
}
```

**Longest Streak Calculation:**

- Similar approach but iterate through all dates in database
- Track maximum consecutive days found
- More complex query - may need to use SQL window functions or iterate through all dates

### 8.4 Performance Considerations

- **Lazy Loading:** Calculate statistics only when Statistics Screen is opened (not on every page change)
- **Caching:** Cache statistics results in service layer (invalidate on new page view)
- **Database Indexes:** Proper indexes on `session_date` and `page_number` for fast queries
- **SQL Aggregations:** Use `COUNT(DISTINCT)` efficiently in database (not in app code)
- **Date Queries:** Use date string comparisons (YYYY-MM-DD format) for fast filtering
- **No Debouncing Needed:** Record all page views (use DISTINCT for unique counts when needed)
- **Statistics Cache:** Store `_cachedStatistics` in service class, invalidate on `recordPageView()`
- **Async Operations:** Record page views asynchronously (fire-and-forget) to avoid blocking UI

---

## 9. Edge Cases

### 9.1 Timezone Changes

- **Issue:** User travels across timezones
- **Solution:** Store all dates in UTC, convert to local timezone for display
- **Alternative:** Store dates as date-only strings (YYYY-MM-DD) in local timezone

### 9.2 Clock Manipulation

- **Issue:** User changes device clock forward/backward
- **Solution:** Validate timestamps are reasonable (not too far in future/past)
- **Prevention:** Use server time if available (future enhancement)

### 9.3 Same Page Multiple Times

- **Issue:** User reads same page multiple times in same day
- **Solution:** Count unique pages per day (not total views)
- **Query:** Use `COUNT(DISTINCT page_number)`

### 9.4 Streak Calculation Edge Cases

- **Issue:** User reads at 11:59 PM, then 12:01 AM next day
- **Solution:** Count both days if within reasonable time window
- **Note:** Standard behavior: each day counts separately

### 9.5 Empty Statistics

- **Issue:** User has no reading history yet
- **Solution:** Show empty state with encouraging message
- **Display:** "ابدأ القراءة لتتبع تقدمك!" (Start reading to track your progress!)

### 9.6 Rapid Page Navigation

- **Issue:** User swipes through pages very quickly
- **Solution:** Record all page views (no debouncing)
- **Rationale:** Use `COUNT(DISTINCT page_number)` for unique page counts
- **Benefit:** More accurate session tracking, can show "X sessions today"
- **Note:** For unique pages, database handles deduplication automatically with DISTINCT

### 9.7 Data Reset

- **Issue:** User wants to reset all progress
- **Solution:** Provide "Clear All Data" option in Settings (with confirmation)
- **Privacy:** Important for user control

---

## 10. Acceptance Criteria

### Functional Criteria

✅ User's page views are automatically tracked when reading
✅ Statistics calculate correctly (today, week, month, all-time)
✅ Reading streak calculates consecutive days correctly
✅ Overall progress shows correct percentage (unique pages / 604)
✅ Statistics display correctly in Statistics Screen
✅ Progress updates automatically after reading sessions
✅ Empty state displays when no reading history exists
✅ Statistics persist across app restarts
✅ Data can be cleared/reset if needed

### UI/UX Criteria

✅ Statistics screen has clear, readable layout
✅ Numbers display in Eastern Arabic numerals
✅ Progress bars animate smoothly
✅ Cards have appropriate spacing and typography
✅ RTL layout works correctly
✅ Colors and styles match app theme
✅ Loading states are handled gracefully
✅ Error states show user-friendly messages
✅ Navigation to statistics screen is intuitive

### Performance Criteria

✅ Statistics calculation completes in < 200ms
✅ Page view recording completes in < 50ms
✅ No UI lag during reading
✅ Statistics screen loads in < 300ms
✅ Database queries are optimized (indexed)

### Accuracy Criteria

✅ Page counts are accurate (no double-counting)
✅ Streaks calculate correctly (consecutive days)
✅ Daily/weekly/monthly boundaries respected
✅ Unique pages counted correctly (not total views)
✅ Percentage calculations are accurate

---

## 11. Future Enhancements (Out of Scope for MVP)

These features are **not** included in v1.0 but may be added later:

- **Reading Goals:** Set daily/weekly page targets
- **Visual Charts:** Graphs showing reading patterns over time
- **Heatmap Calendar:** Visual calendar showing reading days
- **Session Duration Tracking:** Track time spent reading per session
- **Reading Speed Estimation:** Estimate pages per hour
- **Export Statistics:** Export reading data (CSV, JSON)
- **Weekly/Monthly Reports:** Email or in-app reports
- **Achievement Badges:** Milestone celebrations (use carefully)
- **Reading Reminders:** Push notifications for streak maintenance
- **Goal Celebrations:** Celebrate reaching milestones

---

## 12. Testing Requirements

### Unit Tests

- Test page view recording
- Test statistics calculation (today, week, month, all-time)
- Test streak calculation (various scenarios)
- Test unique page counting (same page multiple times)
- Test timezone edge cases
- Test date boundary calculations

### Widget Tests

- Test statistics screen rendering
- Test progress card display
- Test empty state display
- Test loading states
- Test navigation to statistics screen

### Integration Tests

- Test full flow: read pages → view statistics → verify accuracy
- Test persistence across app restarts
- Test streak maintenance over multiple days
- Test data reset functionality

---

## 13. Design Assets

### Icons

- Statistics: `Icons.bar_chart` or `Icons.analytics`
- Progress: `Icons.trending_up`
- Streak: `Icons.local_fire_department` (fire icon) or custom 🔥
- Calendar: `Icons.calendar_today`

### Colors

- Progress bars: `Theme.colorScheme.primary`
- Active streak: `Colors.orange` or `Colors.red`
- Numbers: `Theme.textTheme.headlineLarge?.color`
- Labels: `Theme.textTheme.bodyMedium?.color`

### Animations

- Progress bar fill: 300ms animation
- Number counting: Optional counting animation (future)
- Card appearance: 200ms fade-in

---

## 14. Dependencies

### Existing Dependencies (Already in Project)

- `flutter_riverpod` - State management
- `sqflite` - Database operations
- `path` - Path joining utilities
- `path_provider` - App documents directory access
- Material Design icons (built-in)

### No New Dependencies Required

All required packages are already available in the project.

---

## 15. Implementation Checklist

### Phase 1: Database & Service Layer

- [ ] Create `ReadingSession` model class (`lib/models.dart`)
- [ ] Create `ReadingStatistics` model class
- [ ] Create database schema and migration
- [ ] Implement `ReadingProgressService` interface
- [ ] Implement `SqliteReadingProgressService`
- [ ] Add database initialization code
- [ ] Implement statistics calculation methods
- [ ] Implement streak calculation logic
- [ ] Add to `DbConstants` class
- [ ] Write unit tests for service layer

### Phase 2: State Management

- [ ] Create Riverpod providers for reading progress
- [ ] Create `readingProgressServiceProvider`
- [ ] Create `readingStatisticsProvider`
- [ ] Create `pagesReadTodayProvider`
- [ ] Create `currentStreakProvider`
- [ ] Write tests for providers

### Phase 3: UI Components

- [ ] Create `StatisticsScreen` widget
- [ ] Create `StatisticsListView` widget
- [ ] Create `ProgressCard` widget
- [ ] Create overall progress card component
- [ ] Create today/week/month summary cards
- [ ] Create streak card component
- [ ] Create empty state widget
- [ ] Implement loading states
- [ ] Implement error states
- [ ] Write widget tests

### Phase 4: Integration

- [ ] Integrate page tracking into Mushaf Screen
  - [ ] Record page views on page change
  - [ ] Invalidate statistics after recording
- [ ] Add Reading Progress section to Settings Screen
  - [ ] Display summary statistics
  - [ ] Navigate to Statistics Screen on tap
- [ ] Update constants with new DbConstants
- [ ] Test full integration flow

### Phase 5: Polish & Testing

- [ ] Add animations for progress bars
- [ ] Theme integration testing
- [ ] RTL layout testing
- [ ] Performance optimization
- [ ] Edge case testing (timezones, rapid navigation, etc.)
- [ ] Integration testing
- [ ] User acceptance testing

---

## 16. Notes for Developer

### Code Style

- Follow existing project patterns (functional programming, immutable models)
- Use `@immutable` for all data classes
- Follow existing naming conventions
- Match existing code organization structure
- Use `const` constructors whenever possible

### Database Pattern (Following Bookmarks Pattern)

- **Separate database file:** `reading_progress.db` (same as `bookmarks.db` pattern)
- **Database location:** `{documentsDirectory}/reading_progress.db`
- **Lazy initialization:** `_ensureInitialized()` method called before each operation
- **Database connection:** Stored in `_db` field, checked for null before operations
- **Use `DbConstants`:** For all table/column names (consistency with bookmarks)
- **Error handling:** Exceptions caught and re-thrown with descriptive messages
- **Proper indexing:** Indexes on frequently queried columns (`session_date`, `page_number`)

### State Management

- Use Riverpod code generation (`@riverpod` annotations)
- Run `dart run build_runner build` after adding providers
- Follow existing provider patterns in `providers.dart`
- Cache statistics for performance

### UI/UX

- Match existing app theme and styling
- Follow existing responsive patterns
- Ensure RTL support (text direction awareness)
- Use existing helper functions (e.g., `convertToEasternArabicNumerals`)
- Display dates in Arabic/localized format

### Statistics Accuracy

- **Critical:** Count unique pages per day (not total views)
- **Critical:** Streak must be consecutive days (breaks if day missed)
- **Critical:** Date boundaries must be respected (midnight cutoff)
- Validate calculations with edge cases

### Privacy Considerations

- All data stored locally (no cloud sync)
- User can clear all data anytime
- No personal information tracked
- Consider GDPR/privacy compliance for future features

---

**End of Specification**
