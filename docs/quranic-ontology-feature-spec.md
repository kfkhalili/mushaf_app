# Product Specification: Quranic Ontology Exploration

**Version:** 2.0
**Status:** ✅ IMPLEMENTED
**Author:** Architecture Review
**Date:** 2025-01-27
**Last Updated:** 2025-01-27

---

## Executive Summary

This specification outlines the implementation of a Quranic Ontology Exploration feature that transforms the application from a "Mushaf Reader" into a comprehensive "Quranic Study Tool." The feature enables thematic study (التفسير الموضوعي) by connecting ayahs to a rich ontology of topics.

**Implementation Status:**

✅ **FULLY IMPLEMENTED** - All core features are complete and working in production.

**What Was Implemented:**

- ✅ Contextual Discovery (Bottom-Up): Long-tap ayah shows related topics
- ✅ Dedicated Exploration (Top-Down): Explore Hub with search and topic list
- ✅ Topic Detail Page: Complete topic information with verses grouped by surah
- ✅ Database service with fallback support for legacy schema
- ✅ Arabic-only UI display
- ✅ HTML stripping in descriptions
- ✅ Topic filtering (only topics with verses and Arabic names)
- ✅ Topic deduplication by Arabic name
- ✅ Proper error handling and loading states
- ✅ RTL layout throughout

---

## 1. Overview

### 1.1. Objective

To empower "Students of Knowledge" to perform thematic study by:

- Discovering topics related to specific ayahs (bottom-up exploration)
- Exploring the entire topic ontology (top-down exploration)
- Deep-diving into individual topics with complete context

### 1.2. Core Features

1. **Contextual Discovery (Bottom-Up):** Long-tap an ayah to see all related Quranic topics
2. **Dedicated Exploration (Top-Down):** "Explore Hub" for browsing/searching the entire ontology
3. **Topic Detail Page:** Central screen for each topic with description, related topics, and grouped ayahs

### 1.3. User Stories

- **As a student,** when I long-press an ayah, I want to see all topics it belongs to, so I can understand its broader conceptual context.
- **As a student,** I want to browse a "map" of all Quranic concepts, so I can discover new topics and understand relationships.
- **As a student,** when I find a topic (e.g., "الصبر"), I want to see every ayah related to it, so I can study them collectively.
- **As a student,** when reading a topic's description, I want to tap on other topics mentioned, so I can fluidly explore the ontology.

---

## 2. Technical Architecture & Data

### 2.1. Database (`topics.db`)

**Asset Location:** `assets/db/topics.db`

**Initialization Pattern:** Follow existing `DatabaseService` pattern using `InitializationMixin`:

- Copy database from assets to writable directory on first launch
- Use `_initDb()` pattern from `DatabaseService`
- Handle initialization errors with proper exceptions

**Constants:** All database table names, column names, and configuration values are centralized in `constants.dart` following the existing `DbConstants` pattern. This includes table names (`topics`, `TopicVerseMap`, `RelatedTopicsMap`), column identifiers, and the database filename (`topics.db`).

### 2.2. Database Schema Support

**IMPLEMENTATION NOTE:** The service supports both normalized tables (`TopicVerseMap`, `RelatedTopicsMap`) and legacy schema (string blobs in `ayahs` and `related_topics` columns).

**Current Status:**

- ✅ Service includes fallback logic to parse legacy string columns
- ⏸️ Pre-processing script is optional (not required for functionality)
- ✅ Service checks for table existence and uses appropriate query method

**Future Enhancement:** Pre-processing script (`scripts/preprocess_topics_db.dart`) can be created to:

1. Reads every row in the `topics` table
2. Parses `ayahs` string (e.g., `"2:85, 2:113, 3:55"`)
3. Parses `related_topics` string (e.g., `"1, 5, 22"`)
4. Creates and populates two normalization tables:

**Table 1: `TopicVerseMap`**

```sql
CREATE TABLE TopicVerseMap (
    map_id INTEGER PRIMARY KEY AUTOINCREMENT,
    topic_id INTEGER NOT NULL,
    surah_number INTEGER NOT NULL,
    ayah_number INTEGER NOT NULL,
    FOREIGN KEY (topic_id) REFERENCES topics (topic_id)
);

CREATE INDEX idx_topicverse_topic ON TopicVerseMap(topic_id);
CREATE INDEX idx_topicverse_ayah ON TopicVerseMap(surah_number, ayah_number);
```

**Table 2: `RelatedTopicsMap`**

```sql
CREATE TABLE RelatedTopicsMap (
    map_id INTEGER PRIMARY KEY AUTOINCREMENT,
    source_topic_id INTEGER NOT NULL,
    related_topic_id INTEGER NOT NULL,
    FOREIGN KEY (source_topic_id) REFERENCES topics (topic_id),
    FOREIGN KEY (related_topic_id) REFERENCES topics (topic_id)
);

CREATE INDEX idx_relatedtopics_source ON RelatedTopicsMap(source_topic_id);
```

5. **After population, drop columns** `ayahs` and `related_topics` from `topics` table to save space.

**Validation:** Script must validate:

- No duplicate entries in mapping tables
- All foreign keys reference existing topics
- All ayah references are valid (surah 1-114, ayah > 0)

### 2.3. Data Models

**File:** `lib/models/ontology_models.dart`

**Pattern:** Immutable data models following existing codebase conventions with `@immutable` annotation and proper equality operators.

**Models:**

1. **`Topic`**: Represents a Quranic topic with:

   - Identity: `topicId`, `name` (English, optional), `arabicName` (required, trimmed)
   - Hierarchy: `parentId`, `thematicParentId`, `ontologyParentId`
   - Metadata: `description` (HTML content, stripped for display), `wikiLink`
   - Classification: `isThematic`, `isOntology` flags

   **Parsing Logic:**

   - `arabicName` is trimmed and never falls back to English name (Arabic-only display requirement)
   - Empty strings used for missing Arabic names instead of English fallback
   - Uses `parseInt` helper from `lib/utils/parsing_helpers.dart` for all numeric parsing

2. **`VerseReference`**: Lightweight reference to a Quranic verse with:
   - `surahNumber`, `ayahNumber`
   - Helper `ayahKey` property matching existing codebase pattern for ayah identification

**Equality:** Both models implement equality based on primary keys (`topicId` for `Topic`, `surahNumber` + `ayahNumber` for `VerseReference`).

### 2.4. Ontology Service

**File:** `lib/services/ontology_service.dart`

**Pattern:** Follows existing service patterns (similar to `DatabaseService`, `SearchService`):

**Initialization:**

- Uses `InitializationMixin` for lazy, thread-safe initialization
- Copies database from assets to writable directory on first launch
- Uses read-only database connection with `singleInstance: true` for connection reuse
- **Note:** No PRAGMA busy_timeout for read-only databases (iOS throws exceptions, not needed for read-only operations)
- Handles initialization errors with proper exception hierarchy

**Database Schema Support:**
The service implements dual-mode support for backward compatibility:

1. **Normalized Schema** (Preferred): Uses `TopicVerseMap` and `RelatedTopicsMap` tables for efficient queries
2. **Legacy Schema** (Fallback): Parses string blobs (`ayahs`, `related_topics` columns) when normalized tables don't exist

**Fallback Strategy:**

- Checks table existence via `sqlite_master` before querying
- Falls back to parsing string columns if normalized tables are absent
- For `getTopicsForAyah`: Uses LIKE query at database level, then filters exact matches in memory
- For `getVersesForTopic`: Parses comma-separated verse format (e.g., "2:85, 2:113, 3:55")
- For `getRelatedTopics`: Parses comma-separated topic IDs format (e.g., "1, 5, 22")

This allows the feature to work immediately without requiring database pre-processing, while optimizing for normalized schema when available.

**Core Methods:**

- **`getTopicById(topicId)`**: Fetches a single topic by ID. Throws `DatabaseNotFoundException` if not found.

- **`getTopicsForAyah(surahNumber, ayahNumber)`**: Returns all topics associated with a specific verse.

  - **Normalized mode:** JOINs with `TopicVerseMap` for efficient querying
  - **Legacy mode:** Uses LIKE query at database level, then filters exact matches in memory
  - Results sorted by Arabic name

- **`getVersesForTopic(topicId)`**: Returns all verses associated with a topic.

  - **Normalized mode:** Direct query from `TopicVerseMap`
  - **Legacy mode:** Parses comma-separated verse format (e.g., "2:85, 2:113, 3:55")
  - Results sorted by surah, then ayah number

- **`getRelatedTopics(sourceTopicId)`**: Returns topics marked as related to the given topic.

  - **Normalized mode:** JOINs with `RelatedTopicsMap`
  - **Legacy mode:** Parses comma-separated topic IDs format (e.g., "1, 5, 22"), then queries by ID list
  - Results sorted by Arabic name

- **`getParentTopic(parentId)`**: Fetches parent topic, returns null if not found
- **`getRootTopics()`**: Returns topics where `parent_id IS NULL`, sorted by Arabic name
- **`getRootTopicsByHierarchy(thematic)`**: Returns root topics filtered by hierarchy type:
  - `thematic=true`: Topics where `thematic_parent_id IS NULL`
  - `thematic=false`: Topics where `ontology_parent_id IS NULL`
- **`getChildTopics(topicId, thematic)`**: Returns direct children of a topic in specified hierarchy
- **`searchTopics(query)`**: Searches by English or Arabic name using LIKE pattern matching, returns empty list for empty queries

### 2.5. Riverpod Providers

**File:** `lib/providers.dart` (add to existing file)

**Pattern:** Follows existing provider architecture with code generation.

**Provider Types:**

1. **Service Provider** (`ontologyServiceProvider`):

   - `@Riverpod(keepAlive: true)` - Long-lived service instance
   - Manages service lifecycle with proper cleanup on dispose
   - Handles initialization errors with proper exception propagation

2. **Data Providers** (auto-disposing unless specified):
   - **`topicById(topicId)`**: Fetches single topic
   - **`topicsForAyah(surahNumber, ayahNumber)`**: Topics for a specific verse
   - **`versesForTopic(topicId)`**: Verses for a specific topic
   - **`relatedTopics(sourceTopicId)`**: Related topics for a topic
   - **`rootTopics()`**: All root topics (`@Riverpod(keepAlive: true)`)
   - **`rootTopicsByHierarchy(thematic)`**: Root topics by hierarchy (`@Riverpod(keepAlive: true)`) - **kept alive to prevent repeated queries**
   - **`childTopics(topicId, thematic)`**: Direct child topics
   - **`searchTopics(query)`**: Search results (returns empty list for empty queries)

**Performance Consideration:** `rootTopicsByHierarchyProvider` uses `keepAlive: true` to cache results and prevent unnecessary repeated queries when widgets rebuild.

---

## 3. Feature 1: Contextual Discovery (Long-Tap Menu)

### 3.1. Integration Point

**File:** `lib/widgets/ayah_context_menu.dart`

Modify existing `AyahContextMenu` widget to accept and display related topics.

### 3.2. Implementation

**Pattern:** Extends existing `AyahContextMenu` widget with topics section.

**Behavior:**

- Watches `topicsForAyahProvider(surahNumber, ayahNumber)` using Riverpod
- Displays topics as tappable chips in a `Wrap` widget (RTL alignment)
- Filters out topics without Arabic names
- Shows loading indicator while fetching topics
- Handles errors gracefully (hidden on error)
- **No section heading** - topics appear directly below bookmark section with divider

**Interaction:**

- Tapping a topic chip:
  1. Closes the context menu
  2. Navigates to `TopicDetailScreen` with the selected topic ID
  3. Uses standard `MaterialPageRoute` navigation

**UI Details:**

- Uses `Chip` widgets with RTL text direction
- `InkWell` wrapper for tap feedback
- Spacing and padding aligned with existing menu design

---

## 4. Feature 2: Dedicated Exploration (Explore Hub)

### 4.1. Entry Point

**Integration Points:**

1. **`lib/screens/selection_screen.dart`**:

   - Adds `onExplorePressed` callback to `AppHeader`
   - Navigates to `ExploreHubScreen` using standard `MaterialPageRoute`

2. **`lib/widgets/shared/app_header.dart`**:
   - Adds optional `onExplorePressed` parameter
   - Displays explore icon (`Icons.explore_outlined`) positioned before bookmark icon (RTL layout)
   - Uses standard header icon sizing and styling

### 4.2. Explore Hub Screen

**File:** `lib/screens/explore_hub_screen.dart`

**Architecture:**

- `ConsumerStatefulWidget` managing search query state
- Uses `rootTopicsByHierarchyProvider(false)` for ontology hierarchy (kept alive to prevent repeated queries)
- Dynamically switches between root topics and search results based on query

**Features:**

1. **Search Bar:**

   - RTL layout with `suffixIcon` (search icon on right)
   - Text input with RTL text direction and right alignment
   - Real-time filtering using `searchTopicsProvider`

2. **Topic Filtering Pipeline:**

   - **Step 1:** Filter topics without Arabic names
   - **Step 2:** Deduplicate by Arabic name (handles duplicate names with different IDs)
   - **Step 3:** Async filter to remove topics without verses (checks `versesForTopicProvider` for each topic)
   - Uses `FutureBuilder` to handle async filtering gracefully

3. **Display:**

   - Flat `ListView` with `ListTile` items (no hierarchical expansion)
   - Arabic-only display (no English subtitles)
   - Chevron icon on left side (RTL layout pointing left)
   - Tap navigation to `TopicDetailScreen`

4. **Error Handling:**
   - Loading states with `CircularProgressIndicator`
   - Error display with icon and message
   - Debug logging for development

**Performance:**

- `rootTopicsByHierarchyProvider` uses `keepAlive: true` to cache results
- Async filtering happens in batches to avoid blocking UI
- Empty query state shows all root topics (no unnecessary search)

---

## 5. Feature 3: Topic Detail Page

### 5.1. Topic Detail Screen

**File:** `lib/screens/topic_detail_screen.dart`

**Architecture:** `ConsumerStatefulWidget` managing three async data streams (topic, verses, related topics) with state for verse grouping.

**HTML Stripping:** `_stripHtmlTags` method removes all HTML tags using regex pattern matching, normalizes whitespace, and returns plain text suitable for iOS display (no HTML rendering support).

**Helper Methods:**

- `_groupVersesBySurah`: Groups `VerseReference` list by `surahNumber` into a map for organized display
- `_navigateToAyah`: Fetches page number from `DatabaseService`, pops navigation stack to first route (`SelectionScreen`), then pushes `MushafScreen` with correct initial page. Handles errors with `SnackBar` messages.

---

## 6. Performance Considerations

### 6.1. Database Queries

- **Table Existence Checks:** Service checks for normalized tables before querying, avoiding unnecessary fallback overhead
- **Fallback Optimization:** Legacy queries use LIKE patterns at database level before in-memory filtering
- **Index Usage:** Normalized tables support efficient indexed queries (when available)
- **Connection Reuse:** Single instance database connection with `singleInstance: true`

### 6.2. Provider Caching

- **KeepAlive Strategy:** `rootTopicsByHierarchyProvider` uses `keepAlive: true` to prevent repeated queries on widget rebuilds
- **Auto-Disposal:** Data providers auto-dispose when not watched, reducing memory footprint
- **Future Caching:** Riverpod caches Future results automatically per provider instance

### 6.3. UI Loading States

- **Async Operations:** All database operations wrapped in `FutureBuilder` or `AsyncValue.when()` for proper loading states
- **Nested Futures:** Surah names and ayah texts loaded incrementally with individual `FutureBuilder` widgets
- **Progressive Rendering:** Topics filtered progressively (Arabic names → deduplication → verse checking)

### 6.4. Memory Management

- **Topic Filtering:** Async verse checking happens in batches to avoid blocking
- **Error Suppression:** Non-critical errors (missing verses) silently filtered rather than blocking UI
- **Widget Disposal:** Proper cleanup of controllers and state in widget lifecycle methods

---

## 7. Error Handling

### 7.1. Database Errors

**Exception Hierarchy:**

- Uses existing `DatabaseException` types (`DatabaseNotInitializedException`, `DatabaseNotFoundException`, `DatabaseConnectionException`)
- Service methods throw exceptions for critical errors (not initialized, topic not found)
- Fallback methods return empty lists for missing data (non-critical)

**Pattern:**

- Critical errors propagate through provider layer
- Non-critical errors (missing verses, empty lists) handled gracefully with empty state UI
- Debug logging with `debugPrint()` for development diagnostics

### 7.2. UI Error States

**Handling Strategy:**

- **Loading:** Show `CircularProgressIndicator` for all async operations
- **Empty States:** Display user-friendly Arabic messages ("لا توجد نتائج", "لا توجد آيات مرتبطة بهذا الموضوع")
- **Errors:** Show error icon with message, or gracefully hide (context-dependent)
- **Missing Data:** Null descriptions, empty lists handled conditionally (sections hidden if empty)

**User Experience:**

- Errors don't block navigation
- Empty states provide context
- Debug information logged but not exposed to users

---

## 8. Testing Strategy

### 8.1. Unit Tests

- Test `OntologyService` methods with mock database
- Test model parsing (`Topic.fromMap`, `VerseReference.fromMap`)
- Test verse grouping logic

### 8.2. Integration Tests

- Test database initialization and asset copying
- Test provider initialization and disposal
- Test navigation flows

### 8.3. Acceptance Tests

- Long-tap ayah → see topics menu
- Tap topic chip → navigate to detail screen
- Tap verse in detail → navigate to mushaf screen
- Search topics → see filtered results

---

## 9. Migration & Deployment

### 9.1. Pre-Processing Script

- Create `scripts/preprocess_topics_db.dart`
- Validate normalized data
- Generate pre-processed `topics.db` for bundling

### 9.2. Database Versioning

- Consider adding version check for `topics.db`
- Future: Support database updates via migrations

### 9.3. Asset Management

- Add `topics.db` to `pubspec.yaml` assets
- Ensure database is copied correctly on first launch

---

## 10. Acceptance Criteria

1. ✅ **Bottom-Up:** Long-tapping an ayah shows context menu with related topics section
2. ✅ **Bottom-Up:** Tapping topic chip closes menu and navigates to `TopicDetailScreen`
3. ✅ **Top-Down:** `selection_screen.dart` `AppHeader` shows "Explore" icon
4. ✅ **Top-Down:** Tapping "Explore" icon navigates to `explore_hub_screen.dart`
5. ✅ **Top-Down:** Explore Hub shows filtered list (topics with verses and Arabic names only)
6. ✅ **Top-Down:** Topics are deduplicated by Arabic name
7. ✅ **Detail Page:** `TopicDetailScreen` only shows if topic has verses
8. ✅ **Detail Page:** `TopicDetailScreen` displays description with HTML stripped
9. ✅ **Detail Page:** Related topics section (no heading) shows as chips
10. ✅ **Detail Page:** "الآيات ذات الصلة" section shows collapsible `ExpansionTile` per surah
11. ✅ **Detail Page:** Expanding tile shows `ListTile` for each verse with full Arabic text
12. ✅ **Navigation:** Tapping verse `ListTile` navigates to MushafScreen at correct ayah
13. ✅ **UI:** Arabic-only display throughout (no English text)
14. ✅ **UI:** RTL layout with proper icon positioning
15. ✅ **Performance:** Provider caching prevents repeated queries
16. ✅ **Database:** Fallback support for legacy schema

---

## 11. Out of Scope / Not Implemented

- ✅ **Graph visualization** - Removed per user feedback (not valuable)
- ✅ **Thematic/Ontological toggle** - Removed per user feedback (no clear distinction)
- ✅ **Topic hierarchy expansion** - Not implemented (flat list only)
- Bookmarking topics (ayahs only)
- Editing topics (read-only)
- English localization (Arabic-only UI) ✅ Implemented
- HTML rendering in descriptions (iOS app displays plain text only) ✅ Implemented

---

## 12. Future Enhancements

- Tappable topic links in descriptions (extract `<topic data-id="...">` tags)
- Topic favorites/bookmarks
- Export topic study sessions
- Topic-based reading plans
- Advanced graph filtering and search

---

## Appendix: Files to Create/Modify

### New Files

- `lib/models/ontology_models.dart` ✅
- `lib/services/ontology_service.dart` ✅
- `lib/screens/explore_hub_screen.dart` ✅
- `lib/screens/topic_detail_screen.dart` ✅
- `scripts/preprocess_topics_db.dart` ⏸️ (Optional - not required due to fallback support)

### Modified Files

- `lib/constants.dart` (add topics DB constants) ✅
- `lib/providers.dart` (add ontology providers) ✅
- `lib/widgets/ayah_context_menu.dart` (add topics display) ✅
- `lib/widgets/shared/app_header.dart` (add explore icon) ✅
- `lib/screens/selection_screen.dart` (add explore handler) ✅
- `pubspec.yaml` (add topics.db asset) ✅

---

**End of Specification**
