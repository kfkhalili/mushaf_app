# Mushaf Reading Feature - Product Specification

**Version:** 1.0
**Date:** January 2025
**Status:** 📋 Ready for Implementation
**Priority:** High (Core Feature)

---

## 1. Overview

### 1.1 Purpose

The Mushaf Reading feature is the core functionality of the app, enabling users to read the Quran in an authentic, beautiful format. It supports **two distinct Mushaf layouts** (Uthmani and Indopak) with adaptive font sizing and seamless layout switching that preserves reading position using percentage-based mapping.

### 1.2 Goals

- **Authentic Rendering:** Display Quranic text with accurate Arabic script and proper formatting
- **Dual Layout Support:** Support both Uthmani (15-line) and Indopak (13-line) layouts
- **Adaptive Font Sizing:** Automatically adjust font sizes based on screen dimensions for optimal readability
- **Page-Specific Fonts:** Load page-specific fonts for Uthmani layout to ensure authentic typography
- **Seamless Layout Switching:** Preserve reading position when switching between layouts using percentage-based mapping
- **Smooth Navigation:** Horizontal swipe between pages with smooth animations
- **Performance:** Fast page loading with efficient font caching

### 1.3 Success Metrics

- Page load time: < 200ms average
- Font loading: < 100ms average (cached)
- Layout switch: < 300ms (including page calculation and navigation)
- User satisfaction with readability (font size appropriateness)
- Layout switch success rate (user remains at correct relative position)

---

## 2. User Stories

### Primary Stories

1. **As a user**, I want to read the Quran page by page, so I can follow the traditional Mushaf format
2. **As a user**, I want to swipe horizontally between pages, so I can navigate naturally
3. **As a user**, I want to choose between Uthmani and Indopak layouts, so I can read in my preferred style
4. **As a user**, I want font sizes to adapt to my screen size, so text is always readable
5. **As a user**, I want to switch layouts without losing my place, so I can compare or change preferences seamlessly
6. **As a user**, I want the app to remember my last read page, so I can continue where I left off

### Secondary Stories

7. **As a user**, I want pages to load quickly, so reading is smooth and uninterrupted
8. **As a user**, I want to see which page I'm on, so I can track my progress
9. **As a user**, I want to navigate to specific pages (from Surah, Juz, or Page list), so I can jump to any location
10. **As a user**, I want smooth page transitions, so reading feels natural

---

## 3. Feature Requirements

### 3.1 Layout System

#### 3.1.1 Supported Layouts

**Uthmani (15 Lines)**
- **Total Pages:** 604
- **Lines Per Page:** 15
- **Font System:** Page-specific fonts (604 unique fonts, one per page)
- **Font Family Pattern:** `Page1`, `Page2`, ..., `Page604`
- **Database Files:**
  - Layout: `uthmani-15-lines.db`
  - Script: `qpc-v2.db`
- **Display Name:** "عثماني (١٥ سطر)"
- **Font File Pattern:** `assets/fonts/qpc-v2-page-by-page-fonts/p{pageNumber}.ttf`

**Indopak (13 Lines)**
- **Total Pages:** 849
- **Lines Per Page:** 13
- **Font System:** Single font for all pages
- **Font Family:** `IndopakFont`
- **Database Files:**
  - Layout: `indopak-13-lines-layout-qudratullah.db`
  - Script: `indopak-nastaleeq.db`
- **Display Name:** "إندوباك (١٣ سطر)"
- **Font File:** `assets/fonts/indopak-font.ttf`

#### 3.1.2 Layout Differences

| Aspect | Uthmani (15 Lines) | Indopak (13 Lines) |
|--------|-------------------|-------------------|
| **Total Pages** | 604 | 849 |
| **Lines Per Page** | 15 | 13 |
| **Font System** | 604 page-specific fonts | 1 shared font |
| **Script Style** | Uthmani script | Nastaleeq script |
| **Page Breaks** | Standard Mushaf breaks | Different page breaks |
| **Typography** | Authentic page-by-page rendering | Consistent script style |

#### 3.1.3 Layout Selection

- **Storage:** User preference stored in `SharedPreferences` via `mushafLayoutSettingProvider`
- **Access:** Settings Screen → Layout dropdown
- **Default:** Uthmani (15 lines)
- **Persistence:** Layout choice persists across app sessions

---

### 3.2 Font Loading System

#### 3.2.1 Adaptive Font Size

**Concept:**
Font sizes automatically adapt to screen dimensions for optimal readability across different device sizes.

**Implementation:**
```
1. Calculate screen scale factor:
   scaleFactor = screenWidth / referenceScreenWidth

2. Calculate base font size:
   baseFontSize = layoutMaxFontSize[layout] * scaleFactor

3. Apply clamping:
   fontSize = baseFontSize.clamp(minFontSize, maxFontSize)
```

**Layout-Specific Maximums:**
- **Uthmani:** 20.0 (base)
- **Indopak:** 24.0 (base)

**Font Size Ranges:**
- **Ayah Text:** 16.0 - 30.0
- **Surah Name:** 22.0 - 40.0
- **Surah Header:** 24.0 - 44.0
- **Basmallah:** 15.0 - 28.0

**Reference Screen Dimensions:**
- **Width:** 428.0 (reference for scaling)
- **Height:** 926.0 (for future use)

#### 3.2.2 Page-Specific Font Loading (Uthmani)

**Why Page-Specific Fonts:**
Each page in the Uthmani Mushaf has unique typography to match authentic print layouts. Different pages may have different letter spacing, word positioning, or script variations.

**Loading Process:**
```
1. Check font cache (key: "uthmani15Lines_pageNumber")
2. If cached → return immediately
3. If not cached:
   a. Construct font family name: "Page{pageNumber}"
   b. Load font file: "assets/fonts/qpc-v2-page-by-page-fonts/p{pageNumber}.ttf"
   c. Register font with FontLoader
   d. Cache font family name
   e. Return font family name
```

**Font Naming Convention:**
- Font Family: `Page1`, `Page2`, ..., `Page604`
- Asset File: `p1.ttf`, `p2.ttf`, ..., `p604.ttf`

**Caching Strategy:**
- Fonts loaded per-page are cached by layout+page key
- Cache persists for app session duration
- Reduces loading time on revisits

#### 3.2.3 Shared Font Loading (Indopak)

**Single Font for All Pages:**
- **Font Family:** `IndopakFont`
- **Asset File:** `assets/fonts/indopak-font.ttf`
- **Cache Key:** `indopak13Lines` (layout name)
- **Loading:** Once per app session, reused for all pages

**Benefits:**
- Faster page loads (font already loaded)
- Consistent typography across all pages
- Smaller memory footprint

#### 3.2.4 Common Fonts

**Surah Name Font:**
- **Font Family:** `SurahNames`
- **Asset File:** `assets/fonts/surah-name-v4.ttf`
- **Usage:** Surah name glyphs displayed at surah starts

**Quran Common Font:**
- **Font Family:** `QuranCommon`
- **Asset File:** `assets/fonts/quran-common.ttf`
- **Usage:** Basmallah, common glyphs
- **Layout:** Uthmani only (Indopak uses main font)

---

### 3.3 Page Navigation

#### 3.3.1 Horizontal Swipe Navigation

**Implementation:**
- Uses `PageView.builder` for horizontal scrolling
- Swipe left (RTL) → Next page
- Swipe right (RTL) → Previous page
- Smooth page transitions with built-in animations

**Page Controller:**
- `PageController` manages page state and navigation
- Initial page loaded from preference or navigation parameter
- Page changes tracked and persisted

**Navigation Methods:**
- **Swipe:** User swipes left/right to change pages
- **Programmatic:** `jumpToPage()` or `animateToPage()` for direct navigation
- **From Lists:** Navigate from Surah, Juz, or Page selection lists

#### 3.3.2 Page Persistence

**Last Read Page:**
- Stored in `SharedPreferences` with key `'last_page'`
- Saved on every page change
- Loaded on app launch (Mushaf Screen initialization)
- **Note:** Stored as page number (layout-dependent)

**Persistent Storage Flow:**
```
User navigates to page → Save to SharedPreferences
App launches → Load from SharedPreferences → Navigate to saved page
```

#### 3.3.3 Page Range Validation

**Boundary Checking:**
- Page numbers must be between 1 and layout's total pages
- Uthmani: 1-604
- Indopak: 1-849
- Invalid pages clamped to valid range

---

### 3.4 Layout Switching with Percentage-Based Mapping

#### 3.4.1 Problem Statement

When users switch between Uthmani (604 pages) and Indopak (849 pages), maintaining the same absolute page number causes disorientation because:
- Same page number = different content (e.g., page 302 in Uthmani ≠ page 302 in Indopak)
- Invalid pages (e.g., page 700 in Indopak doesn't exist in Uthmani)
- Loss of reading position context

#### 3.4.2 Solution: Percentage-Based Page Mapping

**Core Concept:**
Map pages based on **relative position** (percentage) through the Quran, not absolute page numbers.

**Calculation Logic:**
```
1. Calculate percentage in source layout:
   percentage = currentPage / totalPages_source

2. Map to target layout:
   targetPage = round(percentage × totalPages_target)

3. Boundary validation:
   targetPage = clamp(targetPage, 1, totalPages_target)
```

**Examples:**

**Example 1: Middle of Quran**
- Source: Page 302 in Uthmani (604 pages)
- Percentage: 302 / 604 = 50%
- Target: 50% × 849 (Indopak) = 424.5 → **Page 425**
- Result: User stays at same relative position (middle of Quran)

**Example 2: Beginning**
- Source: Page 1 in Uthmani (604 pages)
- Percentage: 1 / 604 = 0.17%
- Target: 0.17% × 849 (Indopak) = 1.4 → **Page 1**
- Result: User stays at beginning

**Example 3: End**
- Source: Page 604 in Uthmani (604 pages)
- Percentage: 604 / 604 = 100%
- Target: 100% × 849 (Indopak) = **Page 849**
- Result: User stays at end

#### 3.4.3 Implementation Points

**Location 1: Settings Screen (Primary)**
- When user selects new layout in dropdown:
  1. Read current layout and page (from `currentPageProvider` or `last_page` preference)
  2. Get total pages for current layout (from `totalPagesProvider`)
  3. Calculate percentage: `percentage = currentPage / sourceTotal`
  4. Get total pages for target layout
  5. Calculate target page: `targetPage = round(percentage × targetTotal)`
  6. Update `last_page` preference with target page
  7. Update layout provider
  8. Invalidate database service to reload with new layout

**Location 2: MushafScreen (Secondary - if already viewing)**
- Listen for layout changes:
  1. Calculate target page (same logic as above)
  2. Update `currentPageProvider`
  3. Update `PageController` to jump to target page
  4. Update `last_page` preference

#### 3.4.4 User Experience

**Scenario A: Switch While Viewing MushafScreen**
- User is reading on MushafScreen (page 302, Uthmani)
- User opens Settings and switches to Indopak
- App calculates: 302/604 = 50% → 50% of 849 = 425
- User returns to MushafScreen → **navigates to page 425** (Indopak)
- Fonts reload for new layout
- User sees same relative position (50% through Quran)

**Scenario B: Switch From Selection Screen**
- User is on Selection Screen, last read page was 302 (Uthmani)
- User switches to Indopak in Settings
- Calculation: 302/604 = 50% → 50% of 849 = 425
- Next time user opens MushafScreen → **starts at page 425** (Indopak)

**Visual Feedback:**
- **Option 1: Silent Update (Recommended)**
  - No popup/message
  - Page changes automatically when user returns to MushafScreen
  - Smooth, non-intrusive

- **Option 2: Brief Notification (Optional)**
  - Snackbar: "Navigated to page 425 (mapped from page 302)"
  - More informative but potentially noisy
  - Useful for debugging/testing

**Navigation Animation:**
- **Instant (jumpToPage):** Recommended - layout change feels immediate
- **Animated (animateToPage):** Optional - smoother transition, 300ms duration

---

### 3.5 Database System

#### 3.5.1 Database Files Per Layout

**Uthmani Layout:**
- **Layout Database:** `uthmani-15-lines.db` - Page structure, line layout
- **Script Database:** `qpc-v2.db` - Arabic text (words)
- **Metadata:**
  - `quran-metadata-surah-name.sqlite` - Surah names
  - `quran-metadata-juz.sqlite` - Juz divisions
  - `quran-metadata-hizb.sqlite` - Hizb divisions

**Indopak Layout:**
- **Layout Database:** `indopak-13-lines-layout-qudratullah.db` - Page structure, line layout
- **Script Database:** `indopak-nastaleeq.db` - Arabic text (words)
- **Metadata:** Same as Uthmani (shared)

#### 3.5.2 Database Initialization

**Lazy Initialization:**
- Databases loaded on first access
- Layout-specific databases loaded based on `mushafLayoutSettingProvider`
- Cached for app session duration

**Database Switching:**
- When layout changes, close current databases
- Initialize new layout databases
- Rebuild database service providers

**Location:**
- Databases copied from assets to app documents directory on first use
- Accessible via `path_provider` package

---

## 4. Technical Architecture

### 4.1 Components

#### 4.1.1 MushafScreen

**File:** `lib/screens/mushaf_screen.dart`

**Responsibilities:**
- Main reading interface with `PageView.builder`
- Page navigation and persistence
- Layout change handling
- Integration with bookmarking and memorization features

**Key Features:**
- Horizontal swipe navigation
- Page controller management
- Last page persistence
- Layout change listeners

#### 4.1.2 MushafPageWidget

**File:** `lib/widgets/mushaf_page_widget.dart`

**Responsibilities:**
- Individual page rendering
- Font loading coordination
- Line layout display
- Header/footer display (Juz, Hizb, Surah)

**Key Features:**
- RTL layout support
- Responsive font sizing
- Page-specific font loading (Uthmani)
- Loading states

#### 4.1.3 FontService

**File:** `lib/services/font_service.dart`

**Responsibilities:**
- Dynamic font loading
- Font caching
- Layout-specific font selection

**Methods:**
- `loadFontForPage(pageNumber, layout)` - Load page-specific or shared font
- `loadCommonFont(layout)` - Load common fonts (Surah names, Basmallah)

#### 4.1.4 DatabaseService

**File:** `lib/services/database_service.dart`

**Responsibilities:**
- Layout and script database management
- Page data retrieval
- Layout switching

**Methods:**
- `init(layout)` - Initialize databases for layout
- `switchLayout(layout)` - Switch to different layout
- `getPageLayout(pageNumber)` - Get page structure
- `getPageHeaderInfo(pageNumber)` - Get Juz, Hizb, Surah info
- `getTotalPages()` - Get total pages for current layout

---

### 4.2 State Management (Riverpod)

#### 4.2.1 Providers

**Layout Provider:**
```dart
@Riverpod(keepAlive: true)
class MushafLayoutSetting extends _$MushafLayoutSetting {
  @override
  MushafLayout build() => MushafLayout.uthmani15Lines;

  void setLayout(MushafLayout layout) {
    state = layout;
  }
}
```

**Font Size Provider:**
```dart
@Riverpod(keepAlive: true)
class FontSizeSetting extends _$FontSizeSetting {
  @override
  double build() {
    final layout = ref.watch(mushafLayoutSettingProvider);
    return layoutMaxFontSizes[layout] ?? 20.0;
  }
}
```

**Database Service Provider:**
```dart
@Riverpod(keepAlive: true)
class DatabaseServiceNotifier extends _$DatabaseServiceNotifier {
  @override
  DatabaseService build() {
    final layout = ref.watch(mushafLayoutSettingProvider);
    final service = DatabaseService();
    service.init(layout: layout);
    return service;
  }
}
```

**Total Pages Provider:**
```dart
@riverpod
Future<int> totalPages(Ref ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getTotalPages();
}
```

**Page Data Provider:**
```dart
@riverpod
Future<PageData> pageData(Ref ref, int pageNumber) async {
  final dbService = ref.watch(databaseServiceProvider);
  final fontService = ref.watch(fontServiceProvider);
  final layout = ref.watch(mushafLayoutSettingProvider);

  final layoutData = await dbService.getPageLayout(pageNumber);
  final fontFamily = await fontService.loadFontForPage(pageNumber, layout: layout);

  return PageData(
    layout: layoutData,
    pageFontFamily: fontFamily,
    // ... other data
  );
}
```

---

### 4.3 Helper Functions

#### 4.3.1 Percentage-Based Page Mapping

**Function:**
```dart
int calculateTargetPage(
  int currentPage,
  int sourceTotalPages,
  int targetTotalPages,
) {
  // Calculate percentage
  double percentage = currentPage / sourceTotalPages;

  // Map to target
  double targetPageDouble = percentage * targetTotalPages;

  // Round and clamp
  return targetPageDouble.round().clamp(1, targetTotalPages);
}
```

**Usage:**
- Called when layout changes in Settings Screen
- Called when layout changes while viewing MushafScreen
- Ensures user stays at same relative position

---

## 5. User Experience

### 5.1 Reading Flow

```
App Launch
  ↓
Load last_page preference
  ↓
Initialize MushafScreen at saved page
  ↓
Load page data (layout, fonts, text)
  ↓
Display page
  ↓
User swipes to next/previous page
  ↓
Save new page to preferences
  ↓
Repeat...
```

### 5.2 Layout Switch Flow

```
User on Page 302 (Uthmani, 604 pages)
  ↓
Opens Settings Screen
  ↓
Selects Indopak Layout
  ↓
Calculation Triggered:
- Current: Page 302 (Uthmani)
- Source Total: 604
- Percentage: 302/604 = 50%
- Target Total: 849
- Target Page: 50% × 849 = 425
  ↓
Updates last_page preference → 425
  ↓
Updates layout provider → Indopak
  ↓
Invalidates database service
  ↓
User returns to MushafScreen
  ↓
Loads page 425 (Indopak)
  ↓
User is at same relative position (50% through Quran)
```

### 5.3 Font Loading Flow

**Uthmani (Page-Specific):**
```
Page 302 requested
  ↓
Check cache (key: "uthmani15Lines_302")
  ↓
If cached → Return "Page302"
  ↓
If not cached:
  - Load "assets/fonts/qpc-v2-page-by-page-fonts/p302.ttf"
  - Register as "Page302"
  - Cache "Page302"
  - Return "Page302"
```

**Indopak (Shared):**
```
Page 425 requested
  ↓
Check cache (key: "indopak13Lines")
  ↓
If cached → Return "IndopakFont"
  ↓
If not cached:
  - Load "assets/fonts/indopak-font.ttf"
  - Register as "IndopakFont"
  - Cache "IndopakFont"
  - Return "IndopakFont"
```

---

## 6. Edge Cases & Error Handling

### 6.1 Layout Switching Edge Cases

**Case 1: Page 1 in Source**
- Calculation: 1 / 604 = 0.17%
- Target: 0.17% × 849 = 1.4 → **Page 1** (rounds down)
- **Acceptable:** User stays at beginning

**Case 2: Last Page in Source**
- Calculation: 604 / 604 = 100%
- Target: 100% × 849 = **849** (exact)
- **Acceptable:** User stays at end

**Case 3: Same Layout Selected**
- No calculation needed
- No page change
- User stays on current page

**Case 4: Database Not Loaded**
- If totalPages not available, wait for database to load
- Fallback: Use constant values (604 for Uthmani, 849 for Indopak)
- **Recommendation:** Wait for both source and target totals before calculation

### 6.2 Font Loading Edge Cases

**Case 1: Font File Missing**
- Error: "Font file not found"
- Display: Error message or fallback rendering
- Logging: Error logged for debugging

**Case 2: Font Loading Timeout**
- Issue: Font takes too long to load
- Solution: Show loading indicator, timeout after 5 seconds
- Fallback: Use cached font if available

**Case 3: Memory Pressure**
- Issue: Too many fonts loaded (Uthmani, 604 fonts)
- Solution: Font cache limits (optional: evict oldest fonts)
- Current: All fonts cached for session

### 6.3 Navigation Edge Cases

**Case 1: Invalid Page Number**
- Issue: Page number < 1 or > totalPages
- Solution: Clamp to valid range (1 to totalPages)

**Case 2: Rapid Page Changes**
- Issue: User swipes very quickly
- Solution: Debounce page saves to preferences
- Current: Every page change saves immediately

**Case 3: App Termination During Navigation**
- Issue: App closed mid-swipe
- Solution: Last stable page number saved
- Recovery: Load last saved page on restart

---

## 7. Acceptance Criteria

### Functional Criteria

✅ User can swipe horizontally between pages in MushafScreen
✅ User can select between Uthmani (15 lines) and Indopak (13 lines) layouts
✅ Font sizes adapt automatically to screen dimensions
✅ Page-specific fonts load correctly for Uthmani layout (604 fonts)
✅ Shared font loads correctly for Indopak layout (1 font)
✅ Layout switching preserves relative reading position (percentage-based mapping)
✅ Last read page persists across app sessions
✅ Page numbers are validated against layout's total pages
✅ Page navigation works from Surah, Juz, and Page selection lists
✅ Fonts are cached after first load for faster subsequent access

### Performance Criteria

✅ Page load time: < 200ms average (excluding font load)
✅ Font load time: < 100ms average (cached)
✅ Layout switch: < 300ms (including calculation and navigation)
✅ Smooth page transitions (60 FPS)
✅ No UI lag during page navigation
✅ Database queries optimized (indexed)

### UX Criteria

✅ User stays at same relative position when switching layouts (± 1-2 pages acceptable)
✅ Font sizes are readable on all supported screen sizes
✅ Page transitions feel natural and smooth
✅ Loading states displayed during font/page data loading
✅ Error states handled gracefully with user-friendly messages

---

## 8. Implementation Checklist

### Phase 1: Core Reading Experience

- [x] Implement MushafScreen with PageView.builder
- [x] Implement horizontal swipe navigation
- [x] Implement page persistence (SharedPreferences)
- [x] Implement page range validation
- [x] Integrate with AppHeader and navigation

### Phase 2: Layout System

- [x] Implement MushafLayout enum (Uthmani, Indopak)
- [x] Implement layout selection in Settings
- [x] Implement layout persistence (SharedPreferences)
- [x] Implement database initialization per layout
- [x] Implement database switching logic

### Phase 3: Font System

- [x] Implement FontService for dynamic font loading
- [x] Implement page-specific font loading (Uthmani)
- [x] Implement shared font loading (Indopak)
- [x] Implement font caching
- [x] Implement responsive font size calculation
- [x] Implement font size clamping

### Phase 4: Layout Switching

- [ ] Implement percentage-based page mapping calculation
- [ ] Implement layout switch handler in Settings Screen
- [ ] Implement layout switch handler in MushafScreen
- [ ] Implement total pages provider
- [ ] Test layout switching across various page positions
- [ ] Validate page mapping accuracy

### Phase 5: Polish & Testing

- [ ] Add loading states for font loading
- [ ] Add error handling for missing fonts
- [ ] Optimize font cache management
- [ ] Test on various screen sizes
- [ ] Test layout switching edge cases
- [ ] Performance testing and optimization

---

## 9. Future Enhancements (Out of Scope)

These features are **not** included in v1.0 but may be added later:

- **Custom Font Size:** User-adjustable font size slider
- **Page Zoom:** Pinch-to-zoom for individual pages
- **Night Mode Reading:** Special font/styling for low-light reading
- **Reading Progress Tracking:** Track pages read per session
- **Multiple Layouts:** Support additional Mushaf layouts
- **Font Preloading:** Preload next/previous page fonts for faster navigation
- **Background Reading:** Continue reading with screen off (audio)

---

## 10. Technical Notes

### 10.1 Font Asset Registration

All font files must be declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/fonts/qpc-v2-page-by-page-fonts/
    - assets/fonts/indopak-font.ttf
    - assets/fonts/surah-name-v4.ttf
    - assets/fonts/quran-common.ttf
```

**Note:** Directory paths (with trailing `/`) include all files in the directory.

### 10.2 Database Asset Registration

All database files must be declared in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/db/uthmani-15-lines.db
    - assets/db/indopak-13-lines-layout-qudratullah.db
    - assets/db/qpc-v2.db
    - assets/db/indopak-nastaleeq.db
    - assets/db/quran-metadata-surah-name.sqlite
    - assets/db/quran-metadata-juz.sqlite
    - assets/db/quran-metadata-hizb.sqlite
```

### 10.3 Performance Considerations

**Font Caching:**
- Cache fonts by layout+page key to avoid reloading
- Cache persists for app session
- Consider memory limits for Uthmani (604 fonts)

**Database Caching:**
- Databases initialized once per layout
- Cached for app session
- Close databases when switching layouts

**Page Data Caching:**
- Page data cached in providers (Riverpod)
- Invalidate on layout change
- Rebuild when layout changes

---

## 11. Testing Scenarios

### 11.1 Layout Switching Tests

1. **Start of Book:**
   - Page 1 (Uthmani) → Switch to Indopak → Should map to page 1-2

2. **Middle of Book:**
   - Page 302 (Uthmani, 50%) → Switch to Indopak → Should map to ~425 (50%)

3. **End of Book:**
   - Page 604 (Uthmani, 100%) → Switch to Indopak → Should map to page 849

4. **Multiple Switches:**
   - Switch back and forth multiple times
   - Relative position should remain consistent (±1-2 pages acceptable)

### 11.2 Font Loading Tests

1. **Uthmani Fonts:**
   - Load page 1 → Font "Page1" loads
   - Load page 302 → Font "Page302" loads
   - Revisit page 1 → Font loaded from cache

2. **Indopak Font:**
   - Load any page → Font "IndopakFont" loads
   - Load different page → Same font reused

3. **Layout Switch:**
   - Load page in Uthmani → Switch to Indopak → New font loads
   - Switch back to Uthmani → Original font loads (cached)

### 11.3 Navigation Tests

1. **Swipe Navigation:**
   - Swipe left → Next page
   - Swipe right → Previous page
   - Page transitions smooth

2. **Direct Navigation:**
   - Navigate from Surah list → Correct page loads
   - Navigate from Juz list → Correct page loads
   - Navigate from Page list → Correct page loads

3. **Persistence:**
   - Read page 302 → Close app → Reopen → Page 302 loads

---

**End of Specification**

