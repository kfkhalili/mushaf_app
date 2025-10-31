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
- **Position:** Left side of header Row (RTL layout), after Search icon
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
- Bookmark icon added to left side Row (with Settings/Search)
- Icon placement: After Search icon in the Row
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
- All Arabic text: `textDirection: TextDirection.rtl`
- Content alignment: Right-aligned (use `CrossAxisAlignment.end`)
- Swipe direction: `DismissDirection.endToStart` for RTL
- Chevron icon: Points left (←) for RTL navigation

---

## Quick Implementation Checklist

- [ ] Add `onBookmarkPressed` callback to `AppHeader`
- [ ] Add filled grey bookmark icon to Selection Screen header
- [ ] Create `BookmarksScreen` (full screen)
- [ ] Update `BookmarksListView` with improved RTL layout
- [ ] Update `BookmarkItemCard` with right-aligned content
- [ ] Remove bookmark tab from bottom navigation (if exists)
- [ ] Test RTL layout and alignment
- [ ] Verify icon states (filled grey vs dynamic)

---

**Key Takeaway:** Bookmarks are now accessed via header icon (not bottom nav), and the list has a cleaner RTL layout with right-aligned Arabic content.

