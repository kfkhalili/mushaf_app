# Bookmarks Feature Spec - Key Changes Summary

**Date:** January 2025
**For:** Developer Implementation

---

## What Changed

### 1. **Bookmark Icon Location - Moved to Header**

**Previously:** Bookmarks was a bottom navigation tab (4th tab)
**Now:** Bookmark icon appears in the **header** (top right in RTL layout)

**Two Different Contexts:**

#### Selection Screen
- **Icon:** Always filled grey bookmark icon (`Icons.bookmark`)
- **Color:** Grey (`Colors.grey.shade400` dark / `Colors.grey.shade600` light) - matches Settings/Search icons
- **Position:** **RIGHT side** of header Row (RTL layout) - **separated from Settings/Search**
- **Placement:** Use `trailing` parameter or add to right side of Row (opposite from Settings/Search)
- **Behavior:** Tap icon → Navigate to full-screen `BookmarksScreen`
- **Always visible** when on Selection Screen

#### Mushaf Screen
- **Icon:** Dynamic state (outlined when not bookmarked, filled when bookmarked)
- **Color:** Outlined = grey, Filled = primary theme color
- **Position:** Left side of header (same location, different context)
- **Behavior:** Tap icon → Toggle bookmark for current page
- **Animation:** Scale animation on toggle

### 2. **Bookmarks Access Flow Changed**

**Before:**
```
Selection Screen → Tap "Bookmarks" tab in bottom nav → Bookmarks list
```

**Now:**
```
Selection Screen → Tap filled grey bookmark icon in header → BookmarksScreen (full screen) → Bookmarks list
```

- **Removed:** Bookmarks tab from bottom navigation
- **Added:** Dedicated `BookmarksScreen` (new file)
- **Navigation:** Full screen push navigation (back button to return)

### 3. **Improved RTL List Layout**

The bookmark list cards now have better RTL design:

**Card Layout Changes:**
- **Right-aligned content:** Bookmark icon (📖) + Page number inline on right
- **Better hierarchy:** Page number (22px bold) → Surah (16px) → Meta (13px)
- **Left side:** Subtle chevron (←) for navigation indication
- **Spacing:** 16px padding, 8px margins between cards
- **Corners:** 16px radius (softer look)
- **Borders:** Subtle border for card separation

**Visual Structure:**
```
┌─────────────────────────────────────┐
│ 📖 الصفحة ١٥                    ←  │
│    البقرة                           │
│    منذ يومين • juz01                │
└─────────────────────────────────────┘
```

---

## What to Look For in Spec

### Header Integration (`app_header.dart`)
- Look for `onBookmarkPressed` parameter addition
- **Mushaf Screen:** Bookmark icon added to left side Row (with Settings/Search)
- **Selection Screen:** Bookmark icon added to **RIGHT side** (trailing side) - **separated from Settings/Search**
- Use `trailing` parameter or add to right side of Row for Selection Screen
- Conditional rendering: Show filled grey icon when `onBookmarkPressed` provided

### Selection Screen Changes
- **No bottom navigation tab needed** (removed from spec)
- Add bookmark icon to `AppHeader` with callback
- Navigate to `BookmarksScreen` on icon tap

### New Files Needed
1. **`lib/screens/bookmarks_screen.dart`** - Full screen for bookmarks list
   - Uses `AppHeader` with `showBackButton: true`
   - Contains `BookmarksListView` widget

2. **`lib/widgets/bookmark_item_card.dart`** - Improved RTL card design
   - Right-aligned Column for Arabic content
   - Bookmark icon inline with page number
   - Left-aligned chevron icon

### RTL Layout Requirements
- **CRITICAL:** All Arabic text: `textDirection: TextDirection.rtl`
- **CRITICAL:** Content alignment: **RIGHT-ALIGNED** (use `CrossAxisAlignment.end`)
- **CRITICAL:** All Text widgets: `textAlign: TextAlign.right`
- **CRITICAL:** Content Column: `crossAxisAlignment: CrossAxisAlignment.end`
- **CRITICAL:** Content Row: `mainAxisAlignment: MainAxisAlignment.end`
- **Arrow position:** Chevron on **LEFT** side pointing **LEFT** (←)
- **Text position:** All text on **RIGHT** side, right-aligned
- Swipe direction: `DismissDirection.endToStart` for RTL

---

## Quick Implementation Checklist

- [ ] Add `onBookmarkPressed` callback to `AppHeader`
- [ ] **CRITICAL:** Add filled grey bookmark icon to Selection Screen header **ON THE RIGHT** (trailing side)
- [ ] **CRITICAL:** Icon must be separated from Settings/Search (opposite side)
- [ ] Create `BookmarksScreen` (full screen)
- [ ] **CRITICAL:** Update `BookmarkItemCard` with RIGHT-ALIGNED text content
  - [ ] Wrap in `Directionality(textDirection: TextDirection.rtl)`
  - [ ] Use `CrossAxisAlignment.end` for Column
  - [ ] Use `TextAlign.right` for all Text widgets
  - [ ] Arrow on LEFT side pointing LEFT (←)
  - [ ] Text content on RIGHT side, right-aligned
- [ ] Remove bookmark tab from bottom navigation (if exists)
- [ ] **DO NOT CHANGE** bottom navigation order (السور | الأجزاء | الصفحات)
- [ ] Test RTL layout and alignment (text must appear right-aligned)
- [ ] Verify icon states (filled grey vs dynamic)
- [ ] Verify icon position (right side on Selection Screen)

---

**Key Takeaway:** Bookmarks are now accessed via header icon (not bottom nav), and the list has a cleaner RTL layout with right-aligned Arabic content.

---

## ⚠️ Important Corrections - Read These First!

### 1. Bottom Navigation Order - DO NOT CHANGE
- **Current order (correct):** السور (0) | الأجزاء (1) | الصفحات (2)
- **DO NOT REVERSE** or modify this order
- **NO modifications needed** to `app_bottom_navigation.dart`
- Bookmarks is **NOT** added as a 4th tab
- The spec previously mentioned a different order - **IGNORE that**, keep existing order

### 2. Selection Screen Header Icon Position (CRITICAL - FIXED)
- **MUST BE ON THE RIGHT** (trailing side of header Row)
- **NOT with Settings/Search** (they are on left side)
- Use `trailing` parameter OR add to right side of Row (before Expanded title)
- **Separated** from Settings/Search icons (opposite side of header)
- In RTL layout, this appears visually on the left side, but logically is the trailing/right side of the Row

### 3. Bookmarks List RTL Alignment (CRITICAL - FIXED)
- **ALL TEXT MUST BE RIGHT-ALIGNED** - Text should appear on the right side
- **Arrow MUST be on LEFT** pointing LEFT (←) - Navigation indicator
- Implementation requirements:
  - Wrap entire card in `Directionality(textDirection: TextDirection.rtl)`
  - Column: `crossAxisAlignment: CrossAxisAlignment.end` (RIGHT alignment)
  - Row (with text): `mainAxisAlignment: MainAxisAlignment.end` (RIGHT alignment)
  - All Text widgets: `textAlign: TextAlign.right`
  - Arrow icon: Fixed position on LEFT edge of card

