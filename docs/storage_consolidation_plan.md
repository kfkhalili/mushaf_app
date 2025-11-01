# Storage Strategy Consolidation - Implementation Plan

**Status:** Planning
**Priority:** High
**Effort:** Medium (3-5 days)
**Created:** 2025-01-XX

---

## 1. Executive Summary

### Current Problem
The app uses **three different storage mechanisms** for user data:
- **SharedPreferences** (key-value): Theme, last page
- **In-Memory** (Map): Memorization sessions (lost on restart)
- **SQLite** (multiple databases): Bookmarks, reading progress

This creates inconsistency, data loss risk, and maintenance complexity.

### Solution
Consolidate all user-generated data into a **unified SQLite database** (`app_data.db`), while keeping SharedPreferences only for lightweight app preferences.

### Benefits
- ✅ **No data loss**: Memorization sessions persist across app restarts
- ✅ **Consistency**: Single storage API pattern for all user data
- ✅ **Maintainability**: Easier to maintain, backup, and migrate
- ✅ **Performance**: Single database connection pool
- ✅ **Future-proof**: Easy to add new user data features

---

## 2. Current Storage Analysis

### 2.1 Storage Mechanisms Overview

| Storage Type | Location | Data Stored | Persistence | Issue |
|-------------|----------|-------------|-------------|-------|
| **SharedPreferences** | `SharedPreferences.getInstance()` | `theme_mode`, `last_page` | ✅ Persistent | Works fine for preferences |
| **In-Memory Map** | `InMemoryMemorizationStorage._byPage` | Memorization sessions | ❌ **Lost on restart** | **Critical issue** |
| **SQLite** | `bookmarks.db` | Bookmarks | ✅ Persistent | Separate database |
| **SQLite** | `reading_progress.db` | Reading progress | ✅ Persistent | Separate database |

### 2.2 Current Data Flow

#### Memorization Sessions (Problem Area)
```dart
// lib/services/memorization_storage.dart
class InMemoryMemorizationStorage implements MemorizationStorage {
  static final Map<int, MemorizationSessionState> _byPage = {}; // ❌ Lost on restart
}
```

#### Bookmarks (Working Fine)
```dart
// lib/services/bookmarks_service.dart
// Uses: bookmarks.db with proper schema
```

#### Reading Progress (Working Fine)
```dart
// lib/services/reading_progress_service.dart
// Uses: reading_progress.db with proper schema
```

#### Preferences (Working Fine)
```dart
// Uses SharedPreferences for:
// - theme_mode (String)
// - last_page (Int)
```

---

## 3. Proposed Architecture

### 3.1 Unified Database Schema

**New Database:** `app_data.db`

#### Tables:

1. **`memorization_sessions`** (NEW - migrated from in-memory)
2. **`bookmarks`** (MIGRATED from `bookmarks.db`)
3. **`reading_sessions`** (MIGRATED from `reading_progress.db`)
4. **`user_preferences`** (NEW - for app preferences that need persistence)

### 3.2 Detailed Schema Design

#### Table 1: `memorization_sessions`

```sql
CREATE TABLE IF NOT EXISTS memorization_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  page_number INTEGER NOT NULL,
  first_ayah_index INTEGER NOT NULL,
  last_ayah_index_shown INTEGER NOT NULL,
  pass_count INTEGER NOT NULL DEFAULT 0,
  window_data TEXT NOT NULL, -- JSON: AyahWindowState
  last_updated_at TEXT NOT NULL, -- ISO 8601 timestamp
  created_at TEXT NOT NULL, -- ISO 8601 timestamp

  UNIQUE(page_number)
);

CREATE INDEX idx_memorization_sessions_page ON memorization_sessions(page_number);
CREATE INDEX idx_memorization_sessions_updated ON memorization_sessions(last_updated_at DESC);
```

**JSON Structure for `window_data`:**
```json
{
  "ayahIndices": [0, 1, 2],
  "opacities": [1.0, 0.5, 0.0],
  "tapsSinceReveal": [0, 1, 0]
}
```

#### Table 2: `bookmarks` (Migrated)

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

-- Indexes remain the same
```

#### Table 3: `reading_sessions` (Migrated)

```sql
CREATE TABLE IF NOT EXISTS reading_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_date TEXT NOT NULL, -- ISO 8601 date (YYYY-MM-DD)
  page_number INTEGER NOT NULL,
  timestamp TEXT NOT NULL, -- ISO 8601 timestamp
  duration_seconds INTEGER
);

-- Indexes remain the same
```

#### Table 4: `user_preferences` (NEW - Optional)

```sql
CREATE TABLE IF NOT EXISTS user_preferences (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TEXT NOT NULL -- ISO 8601 timestamp
);
```

**Initial entries:**
- `key: 'last_page'`, `value: '1'`
- Could store: font size, memorization config, etc.

### 3.3 Architecture Decision: Keep SharedPreferences?

**Recommendation:** **Hybrid Approach**

- **Keep SharedPreferences for:** Theme mode (light/dark/sepia/system)
  - Why: Set before ProviderScope initializes (in `main.dart`)
  - Why: Very lightweight, accessed before app fully loads

- **Move to SQLite:**
  - Memorization sessions (critical - currently lost)
  - Last page (optional - could stay in SharedPreferences)
  - Future: Font size, memorization settings, etc.

**Rationale:** SharedPreferences is fine for very lightweight, app-level preferences that need to be read synchronously at startup. User-generated content should be in SQLite.

---

## 4. Implementation Plan

### Phase 1: Database Schema & Service (Day 1)

#### Step 1.1: Create Unified Database Service
- [ ] Create `lib/services/app_data_service.dart`
- [ ] Implement database initialization with all 4 tables
- [ ] Add database version management (start at version 1)
- [ ] Implement `_ensureInitialized()` pattern (same as existing services)

#### Step 1.2: Define Database Constants
- [ ] Add constants to `lib/constants.dart`:
  ```dart
  // App Data Database
  static const String memorizationSessionsTable = 'memorization_sessions';
  static const String userPreferencesTable = 'user_preferences';
  // ... column names
  ```

#### Step 1.3: Create Memorization Storage Implementation
- [ ] Create `SqliteMemorizationStorage` class
- [ ] Implement `MemorizationStorage` interface
- [ ] Add JSON serialization for `AyahWindowState`
- [ ] Add JSON deserialization for loading

**Files to create:**
- `lib/services/app_data_service.dart` (NEW)
- `lib/services/memorization_storage_sqlite.dart` (NEW)

### Phase 2: Migration Logic (Day 2)

#### Step 2.1: Data Migration from Separate Databases
- [ ] Create migration utility: `lib/services/migration_service.dart`
- [ ] Implement `migrateBookmarks()` - Copy from `bookmarks.db` → `app_data.db`
- [ ] Implement `migrateReadingProgress()` - Copy from `reading_progress.db` → `app_data.db`
- [ ] Add migration flag to prevent duplicate migrations

#### Step 2.2: Migration Strategy
```dart
class MigrationService {
  Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool('app_data_migrated') ?? false;

    if (!migrated) {
      await _migrateBookmarks();
      await _migrateReadingProgress();
      await prefs.setBool('app_data_migrated', true);
    }
  }
}
```

#### Step 2.3: Backwards Compatibility
- [ ] Keep old databases during migration period (as backup)
- [ ] Add flag to enable "dual-write" mode (write to both old and new)
- [ ] Plan for eventual removal of old databases (in a future release)

### Phase 3: Update Services (Day 2-3)

#### Step 3.1: Update Bookmarks Service
- [ ] Modify `SqliteBookmarksService` to use `app_data.db` instead of `bookmarks.db`
- [ ] Update initialization to check for migration
- [ ] Test that existing bookmarks still work

#### Step 3.2: Update Reading Progress Service
- [ ] Modify `SqliteReadingProgressService` to use `app_data.db` instead of `reading_progress.db`
- [ ] Update initialization to check for migration
- [ ] Test that existing progress still works

#### Step 3.3: Update Memorization Provider
- [ ] Change `MemorizationSessionNotifier` to use `SqliteMemorizationStorage` instead of `InMemoryMemorizationStorage`
- [ ] Update provider initialization in `lib/providers.dart`
- [ ] Test that memorization sessions persist across restarts

### Phase 4: Testing (Day 3-4)

#### Step 4.1: Unit Tests
- [ ] Test `AppDataService` initialization
- [ ] Test `SqliteMemorizationStorage` save/load/clear
- [ ] Test migration logic (bookmarks, reading progress)
- [ ] Test backwards compatibility

#### Step 4.2: Integration Tests
- [ ] Test memorization session persistence (restart app, verify session exists)
- [ ] Test bookmark migration (verify old bookmarks appear in new database)
- [ ] Test reading progress migration (verify old progress appears)

#### Step 4.3: Manual Testing
- [ ] Create memorization session → restart app → verify session persists
- [ ] Verify bookmarks still work after migration
- [ ] Verify reading progress still works after migration
- [ ] Test with fresh install (no migration)

### Phase 5: Cleanup (Day 5)

#### Step 5.1: Remove Old Code
- [ ] Remove `InMemoryMemorizationStorage` class
- [ ] Remove old database initialization code from bookmarks/reading progress services
- [ ] Update documentation

#### Step 5.2: Optional: Database Cleanup
- [ ] Add utility to remove old database files after successful migration
- [ ] Add this to a future release (not immediately, for safety)

---

## 5. Code Structure

### 5.1 New Files Structure

```
lib/
  services/
    app_data_service.dart          # NEW: Unified database service
    memorization_storage_sqlite.dart  # NEW: SQLite implementation
    migration_service.dart          # NEW: Migration logic
```

### 5.2 Modified Files

```
lib/
  services/
    bookmarks_service.dart         # MODIFIED: Use app_data.db
    reading_progress_service.dart  # MODIFIED: Use app_data.db
    memorization_storage.dart      # MODIFIED: Add SQLite implementation
  providers.dart                   # MODIFIED: Use SqliteMemorizationStorage
  constants.dart                   # MODIFIED: Add new table/column constants
```

### 5.3 Example Implementation

#### `lib/services/app_data_service.dart` (Skeleton)

```dart
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../constants.dart';

class AppDataService {
  Database? _db;
  bool _initialized = false;
  Future<void>? _initFuture;

  Future<void> ensureInitialized() async {
    if (_initialized && _db != null) return;
    _initFuture ??= _doInit();
    await _initFuture;
  }

  Future<void> _doInit() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDirectory.path, 'app_data.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Create all tables
        await _createMemorizationSessionsTable(db);
        await _createBookmarksTable(db);
        await _createReadingSessionsTable(db);
        await _createUserPreferencesTable(db);

        // Create indexes
        await _createIndexes(db);
      },
    );

    _initialized = true;
  }

  Future<void> _createMemorizationSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DbConstants.memorizationSessionsTable} (
        ${DbConstants.idCol} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.pageNumberCol} INTEGER NOT NULL,
        ${DbConstants.firstAyahIndexCol} INTEGER NOT NULL,
        ${DbConstants.lastAyahIndexShownCol} INTEGER NOT NULL,
        ${DbConstants.passCountCol} INTEGER NOT NULL DEFAULT 0,
        ${DbConstants.windowDataCol} TEXT NOT NULL,
        ${DbConstants.lastUpdatedAtCol} TEXT NOT NULL,
        ${DbConstants.createdAtCol} TEXT NOT NULL,
        UNIQUE(${DbConstants.pageNumberCol})
      )
    ''');
  }

  // ... other table creation methods

  Database get database {
    if (_db == null) throw StateError('Database not initialized');
    return _db!;
  }
}
```

#### `lib/services/memorization_storage_sqlite.dart` (Skeleton)

```dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../memorization/models.dart';
import '../constants.dart';
import 'app_data_service.dart';

class SqliteMemorizationStorage implements MemorizationStorage {
  final AppDataService _appDataService;

  SqliteMemorizationStorage(this._appDataService);

  @override
  Future<void> saveSession(MemorizationSessionState state) async {
    await _appDataService.ensureInitialized();
    final db = _appDataService.database;

    final windowJson = jsonEncode({
      'ayahIndices': state.window.ayahIndices,
      'opacities': state.window.opacities,
      'tapsSinceReveal': state.window.tapsSinceReveal,
    });

    await db.insert(
      DbConstants.memorizationSessionsTable,
      {
        DbConstants.pageNumberCol: state.pageNumber,
        DbConstants.firstAyahIndexCol: state.window.ayahIndices.first,
        DbConstants.lastAyahIndexShownCol: state.lastAyahIndexShown,
        DbConstants.passCountCol: state.passCount,
        DbConstants.windowDataCol: windowJson,
        DbConstants.lastUpdatedAtCol: state.lastUpdatedAt.toIso8601String(),
        DbConstants.createdAtCol: DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<MemorizationSessionState?> loadSession(int pageNumber) async {
    await _appDataService.ensureInitialized();
    final db = _appDataService.database;

    final results = await db.query(
      DbConstants.memorizationSessionsTable,
      where: '${DbConstants.pageNumberCol} = ?',
      whereArgs: [pageNumber],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final windowJson = jsonDecode(row[DbConstants.windowDataCol] as String) as Map<String, dynamic>;

    return MemorizationSessionState(
      pageNumber: row[DbConstants.pageNumberCol] as int,
      window: AyahWindowState(
        ayahIndices: List<int>.from(windowJson['ayahIndices']),
        opacities: List<double>.from(windowJson['opacities']),
        tapsSinceReveal: List<int>.from(windowJson['tapsSinceReveal']),
      ),
      lastAyahIndexShown: row[DbConstants.lastAyahIndexShownCol] as int,
      lastUpdatedAt: DateTime.parse(row[DbConstants.lastUpdatedAtCol] as String),
      passCount: row[DbConstants.passCountCol] as int,
    );
  }

  @override
  Future<void> clearSession(int pageNumber) async {
    await _appDataService.ensureInitialized();
    final db = _appDataService.database;

    await db.delete(
      DbConstants.memorizationSessionsTable,
      where: '${DbConstants.pageNumberCol} = ?',
      whereArgs: [pageNumber],
    );
  }
}
```

---

## 6. Migration Strategy

### 6.1 Migration Flow

```
App Starts
  ↓
Check: Has app_data.db been created?
  ↓ NO → Create app_data.db with all tables
  ↓ YES → Check: Has migration been run?
    ↓ NO → Run migration:
      - Copy bookmarks from bookmarks.db → app_data.db
      - Copy reading_sessions from reading_progress.db → app_data.db
      - Set flag: 'app_data_migrated' = true
    ↓ YES → Continue normally
  ↓
App Ready
```

### 6.2 Migration Safety

1. **Backup First:** Read all data from old databases before writing to new
2. **Verify Migration:** After migration, verify data integrity
3. **Rollback Plan:** Keep old databases until migration is verified by users
4. **Dual-Write (Optional):** Write to both old and new databases during transition period

### 6.3 Migration Code Example

```dart
class MigrationService {
  final AppDataService _appDataService;
  final DatabaseService _databaseService;

  MigrationService(this._appDataService, this._databaseService);

  Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool('app_data_migrated_v1') ?? false;

    if (migrated) return;

    await _appDataService.ensureInitialized();
    final newDb = _appDataService.database;

    // Migrate bookmarks
    final oldBookmarksDb = await _openOldDatabase('bookmarks.db');
    final bookmarks = await oldBookmarksDb.query('bookmarks');
    for (final bookmark in bookmarks) {
      await newDb.insert(DbConstants.bookmarksTable, bookmark);
    }
    await oldBookmarksDb.close();

    // Migrate reading sessions
    final oldProgressDb = await _openOldDatabase('reading_progress.db');
    final sessions = await oldProgressDb.query('reading_sessions');
    for (final session in sessions) {
      await newDb.insert(DbConstants.readingSessionsTable, session);
    }
    await oldProgressDb.close();

    // Mark migration complete
    await prefs.setBool('app_data_migrated_v1', true);
  }
}
```

---

## 7. Testing Strategy

### 7.1 Unit Tests

**File:** `test/services/app_data_service_test.dart`

```dart
void main() {
  group('AppDataService', () {
    test('initializes database with all tables', () async {
      // Test that all 4 tables are created
    });

    test('handles concurrent initialization', () async {
      // Test _initFuture pattern
    });
  });

  group('SqliteMemorizationStorage', () {
    test('saves and loads memorization session', () async {
      // Test persistence
    });

    test('clears session correctly', () async {
      // Test deletion
    });

    test('handles JSON serialization correctly', () async {
      // Test AyahWindowState encoding/decoding
    });
  });
}
```

### 7.2 Integration Tests

**File:** `integration_test/storage_persistence_test.dart`

```dart
void main() {
  testWidgets('memorization session persists across app restart', (tester) async {
    // 1. Start app
    // 2. Create memorization session
    // 3. Restart app (simulate)
    // 4. Verify session still exists
  });
}
```

### 7.3 Migration Tests

```dart
void main() {
  group('MigrationService', () {
    test('migrates bookmarks correctly', () async {
      // Create old bookmarks.db with test data
      // Run migration
      // Verify data in app_data.db
    });

    test('does not re-migrate if already migrated', () async {
      // Set migration flag
      // Run migration again
      // Verify no duplicate data
    });
  });
}
```

---

## 8. Rollout Plan

### Phase 1: Development (Week 1)
- ✅ Create implementation plan (this document)
- Implement unified database service
- Implement SQLite memorization storage
- Write unit tests

### Phase 2: Testing (Week 1-2)
- Run integration tests
- Manual testing on development device
- Test migration on device with existing data

### Phase 3: Staged Rollout (Week 2)
- **Beta Release**: Deploy to test users with existing data
- Monitor for migration issues
- Collect feedback

### Phase 4: Full Release (Week 3)
- Deploy to all users
- Monitor error logs for migration issues
- Plan cleanup of old databases (future release)

---

## 9. Risk Assessment & Mitigation

### Risk 1: Data Loss During Migration
- **Probability:** Low
- **Impact:** High
- **Mitigation:**
  - Comprehensive testing before release
  - Backup old databases before migration
  - Verify data integrity after migration
  - Rollback plan (keep old databases)

### Risk 2: Performance Issues
- **Probability:** Low
- **Impact:** Medium
- **Mitigation:**
  - Single database connection pool
  - Proper indexing
  - Async operations
  - Performance benchmarking

### Risk 3: Breaking Existing Features
- **Probability:** Low
- **Impact:** High
- **Mitigation:**
  - Extensive testing
  - Backwards compatibility during migration
  - Gradual rollout

---

## 10. Success Criteria

### Must Have (MVP)
- ✅ Memorization sessions persist across app restarts
- ✅ Existing bookmarks work after migration
- ✅ Existing reading progress works after migration
- ✅ No data loss during migration

### Nice to Have
- ✅ Single unified database for all user data
- ✅ Old databases cleaned up (future release)
- ✅ Performance improvement from unified connection pool

---

## 11. Future Enhancements

After consolidation is complete:

1. **User Preferences Table:**
   - Store font size, memorization config, etc. in SQLite instead of SharedPreferences

2. **Backup/Restore:**
   - Single database makes backup/restore easier
   - Export/import user data

3. **Sync:**
   - Future cloud sync becomes easier with unified schema

4. **Analytics:**
   - Single database makes analytics queries easier

---

## 12. Appendix

### A. Database Schema Constants (to add to `constants.dart`)

```dart
class DbConstants {
  // ... existing constants ...

  // --- App Data Database Tables ---
  static const String memorizationSessionsTable = 'memorization_sessions';
  static const String userPreferencesTable = 'user_preferences';

  // --- Memorization Sessions Columns ---
  static const String firstAyahIndexCol = 'first_ayah_index';
  static const String lastAyahIndexShownCol = 'last_ayah_index_shown';
  static const String passCountCol = 'pass_count';
  static const String windowDataCol = 'window_data';
  static const String lastUpdatedAtCol = 'last_updated_at';
  static const String createdAtCol = 'created_at';

  // --- User Preferences Columns ---
  static const String keyCol = 'key';
  static const String valueCol = 'value';
  static const String updatedAtCol = 'updated_at';
}
```

### B. JSON Schema for Window Data

```json
{
  "ayahIndices": [0, 1, 2],
  "opacities": [1.0, 0.5, 0.0],
  "tapsSinceReveal": [0, 1, 0]
}
```

### C. Migration Checklist

- [ ] Create `app_data_service.dart`
- [ ] Create `memorization_storage_sqlite.dart`
- [ ] Add constants to `constants.dart`
- [ ] Update `bookmarks_service.dart` to use `app_data.db`
- [ ] Update `reading_progress_service.dart` to use `app_data.db`
- [ ] Update `providers.dart` to use `SqliteMemorizationStorage`
- [ ] Create migration service
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Manual testing
- [ ] Deploy to beta
- [ ] Full release

---

**End of Implementation Plan**

