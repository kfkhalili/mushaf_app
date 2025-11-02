# Primary Color Customization Feature Specification

## Overview

The Primary Color Customization feature allows users to personalize their app experience by selecting a custom primary color. This color is applied throughout the app, including ayat highlighting, numbering in selection screens, navigation indicators, and other UI elements that use the theme's primary color.

## Status

✅ **IMPLEMENTED** - Feature is fully functional and integrated into the app.

---

## Feature Goals

1. **Personalization**: Allow users to customize the app's primary color to match their preferences
2. **Visual Consistency**: Apply the selected color consistently across all UI elements
3. **Vibrant Colors**: Ensure the exact color selected by the user is applied without muting or adjustments
4. **Persistent Storage**: Save the user's color preference across app sessions
5. **User-Friendly Interface**: Provide an intuitive color picker with presets and custom color selection

---

## User Interface

### Settings Screen Integration

The color customization feature is integrated into the Settings screen (`lib/screens/settings_screen.dart`) under the "المظهر" (Appearance) section.

#### Color Presets Grid

- **Location**: Settings screen, under "اللون الأساسي" (Primary Color) section
- **Layout**: 5-column grid of circular color swatches
- **Presets**: 10 predefined colors:
  - شرشير (Teal) - `0xFF009688`
  - أزرق (Blue) - `0xFF2196F3`
  - بنفسجي (Purple) - `0xFF9C27B0`
  - أخضر (Green) - `0xFF4CAF50`
  - برتقالي (Orange) - `0xFFFF9800`
  - أحمر (Red) - `0xFFF44336`
  - وردي (Pink) - `0xFFE91E63`
  - أزرق داكن (Dark Blue) - `0xFF1976D2`
  - أخضر داكن (Dark Green) - `0xFF388E3C`
  - بني (Brown) - `0xFF795548`
- **Selection Indicator**: Selected preset shows:
  - Thicker border (3px vs 1px)
  - Check icon
  - Shadow effect

#### Current Color Preview Row

- **Location**: Below the color presets grid
- **Interaction**: Entire row is tappable (wrapped in `InkWell`)
- **Components**:
  - Color circle (32x32) showing current selected color
  - Color name in Arabic (e.g., "شرشير", "لون مخصص" for custom colors)
  - Color lens icon (`Icons.color_lens`) tinted with current color
- **Visual Feedback**: Ripple effect on tap
- **Functionality**: Tapping the row opens the custom color picker dialog

#### Custom Color Picker Dialog

- **Trigger**: Tapping the current color preview row
- **Components**:
  - **Hue Slider**: Full spectrum color wheel (0-360 degrees)
  - **Saturation Slider**: Intensity of color (0.0-1.0)
  - **Brightness Slider**: Lightness of color (0.0-1.0)
  - **Live Preview**: Large preview box showing selected color
  - **Actions**: "إلغاء" (Cancel) and "تطبيق" (Apply) buttons
- **Implementation**: Uses HSV color space for intuitive color selection
- **Storage**: Custom colors are stored as integer values (`Color.value`)

---

## Technical Implementation

### Provider Architecture

#### PrimaryColorNotifier Provider

**Location**: `lib/providers.dart`

```dart
@Riverpod(keepAlive: true)
class PrimaryColorNotifier extends _$PrimaryColorNotifier {
  @override
  int build() {
    // Loads from SharedPreferences synchronously if available
    // Defaults to PrimaryColorConstants.defaultColor (Teal)
  }

  Future<void> setPrimaryColor(int colorValue) async {
    // Updates state and persists to SharedPreferences
  }
}
```

**Responsibilities**:
- Manages primary color state
- Loads initial value from SharedPreferences
- Persists color changes to SharedPreferences
- Provides reactive state updates to UI

**Storage Key**: `'primary_color'` (defined in `PrimaryColorConstants.preferencesKey`)

**Default Color**: `0xFF009688` (Teal)

### Theme Generation

**Location**: `lib/themes.dart`

The app uses Material 3's `ColorScheme.fromSeed()` to generate a complete color palette, but **overrides the primary color** with the exact user-selected color to ensure vibrant, unmuted colors.

#### Theme Builders

1. **`buildLightTheme(int primaryColorValue)`**
   - Generates light theme with custom primary color
   - Uses `ColorScheme.fromSeed().copyWith(primary: seedColor)` to ensure exact color

2. **`buildDarkTheme(int primaryColorValue)`**
   - Generates dark theme with custom primary color
   - Same override pattern as light theme

3. **`buildSepiaTheme(int primaryColorValue)`**
   - Generates sepia theme with custom primary color
   - Uses brown as seed for color scheme generation, but applies user's custom primary color

**Key Implementation Detail**:
```dart
final colorScheme = ColorScheme.fromSeed(
  seedColor: seedColor,
  brightness: Brightness.light,
).copyWith(primary: seedColor);  // Override with exact color
```

This ensures the **exact vibrant color** selected by the user is used throughout the app, rather than Material 3's accessibility-adjusted version.

### Main App Integration

**Location**: `lib/main.dart`

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final AppThemeMode currentThemeMode = ref.watch(themeProvider);
  final primaryColorValue = ref.watch(primaryColorProvider);  // Watches color

  // Generate themes dynamically with custom color
  final lightThemeDynamic = buildLightTheme(primaryColorValue);
  final darkThemeDynamic = buildDarkTheme(primaryColorValue);
  final sepiaThemeDynamic = buildSepiaTheme(primaryColorValue);

  return MaterialApp(
    theme: lightThemeDynamic,
    darkTheme: darkThemeDynamic,
    // ... theme mode logic
  );
}
```

The app watches `primaryColorProvider` and regenerates themes whenever the color changes, ensuring instant visual updates.

### Constants

**Location**: `lib/constants.dart`

#### PrimaryColorConstants Class

- **`defaultColor`**: Default teal color (`0xFF009688`)
- **`defaultSepiaColor`**: Default brown for sepia theme (`0xFF795548`)
- **`preferencesKey`**: SharedPreferences key (`'primary_color'`)
- **`presets`**: List of 10 `ColorPreset` objects with Arabic names

#### ColorPreset Class

```dart
class ColorPreset {
  final String name;  // Arabic name
  final int color;    // Color value as integer

  Color get colorValue => Color(color);
}
```

---

## Color Application Points

The custom primary color is applied throughout the app wherever `theme.colorScheme.primary` is used:

### 1. Selection Screen Numbering
- **Location**: `lib/widgets/shared/leading_number_text.dart`
- **Usage**: Surah numbers, Juz numbers, and page numbers use `theme.colorScheme.primary`
- **Visual**: Bold, vibrant colored numbers

### 2. Ayat Highlighting
- **Location**: `lib/widgets/mushaf_line.dart`
- **Usage**: Bookmarked and selected ayat are highlighted with `theme.colorScheme.primary`
- **Implementation**: Text color changes to primary color for highlighted ayat
- **Key Enhancement**: ValueKey includes primary color value to ensure widgets rebuild when color changes

### 3. Bottom Navigation
- **Location**: `lib/widgets/shared/app_bottom_navigation.dart`
- **Usage**: Selected tab indicator and icon color use primary color

### 4. Statistics Cards
- **Location**: `lib/widgets/statistics_cards.dart`
- **Usage**: Progress indicators and accent colors use primary color

### 5. Search Screen
- **Location**: `lib/screens/search_screen.dart`
- **Usage**: Search icon and accent colors use primary color

### 6. Bookmarks Screen
- **Location**: `lib/widgets/bookmark_item_card.dart`
- **Usage**: Bookmark indicators use primary color

### 7. Memorization Mode
- **Location**: `lib/widgets/countdown_circle.dart`
- **Usage**: Countdown circle background uses primary color

---

## User Flow

### Selecting a Preset Color

1. User navigates to Settings screen
2. Scrolls to "اللون الأساسي" (Primary Color) section
3. Views grid of 10 color presets
4. Taps desired color preset
5. Color is immediately applied across the app
6. Selection indicator (check mark) appears on chosen preset
7. Color is saved to SharedPreferences

### Selecting a Custom Color

1. User navigates to Settings screen
2. Scrolls to "اللون الأساسي" (Primary Color) section
3. Views current color preview row
4. Taps the entire preview row
5. Custom color picker dialog opens
6. User adjusts HSV sliders:
   - **اللون** (Hue): Full color spectrum
   - **التشبع** (Saturation): Color intensity
   - **السطوع** (Brightness): Color lightness
7. Views live preview of selected color
8. Taps "تطبيق" (Apply) button
9. Color is immediately applied across the app
10. Preview row updates to show "لون مخصص" (Custom Color)
11. Color is saved to SharedPreferences

### Persistence and Restoration

1. On app startup, `PrimaryColorNotifier.build()` reads from SharedPreferences
2. If saved color exists, it's loaded and applied
3. If no saved color, defaults to Teal (`0xFF009688`)
4. Theme is generated with the loaded/default color
5. All UI elements reflect the saved color immediately

---

## Technical Details

### Color Storage Format

- **Storage Type**: `int` (using `SharedPreferences.setInt()`)
- **Format**: ARGB color value (e.g., `0xFF009688`)
- **Conversion**: `Color.value` to store, `Color(intValue)` to retrieve

### Color Scheme Generation

- **Method**: Material 3 `ColorScheme.fromSeed()`
- **Override**: `.copyWith(primary: exactColor)` to ensure exact user-selected color
- **Rationale**: Material 3 adjusts colors for accessibility, which can mute vibrant colors. Overriding ensures the exact color is used.

### State Management

- **Provider**: Riverpod code generation (`@Riverpod`)
- **State Type**: `int` (color value)
- **Reactivity**: All widgets using `ref.watch(primaryColorProvider)` automatically rebuild when color changes
- **Persistence**: SharedPreferences for cross-session storage

### Theme Rebuilding

- **Trigger**: When `primaryColorProvider` value changes
- **Scope**: Entire app theme is regenerated
- **Performance**: Theme generation is lightweight, happens synchronously
- **Update Mechanism**: `MaterialApp` rebuilds with new theme, all children widgets get updated theme via `Theme.of(context)`

---

## Edge Cases and Error Handling

### Invalid Color Values

- **Handling**: If SharedPreferences contains invalid color value, defaults to Teal
- **Storage**: Only valid integer color values are stored

### SharedPreferences Failures

- **Loading**: If SharedPreferences read fails, defaults to Teal
- **Saving**: If SharedPreferences write fails, logs error in debug mode but doesn't crash
- **Error Handling**: Try-catch blocks around SharedPreferences operations

### Theme Generation Failures

- **Fallback**: If theme generation fails, app uses default static themes (deprecated but kept for safety)
- **Validation**: Color values are validated before use

---

## Performance Considerations

### Theme Regeneration

- **Frequency**: Only when color changes (user action)
- **Cost**: Minimal - ColorScheme generation is fast
- **Caching**: Themes are not cached (always fresh), but generation is cheap

### Widget Rebuilds

- **Scope**: Only widgets using `theme.colorScheme.primary` rebuild
- **Optimization**: ValueKey in `MushafLine` includes primary color to ensure proper rebuilds
- **Efficiency**: Riverpod's selective rebuilding minimizes unnecessary widget rebuilds

### SharedPreferences Access

- **Synchronous**: Initial load happens synchronously in `build()` method
- **Async Write**: Saves happen asynchronously to avoid blocking UI
- **Caching**: SharedPreferences has internal caching, so reads are fast

---

## Testing Considerations

### Manual Testing Checklist

- [x] Preset colors apply correctly
- [x] Custom color picker works correctly
- [x] Color persists across app restarts
- [x] Color applies to all UI elements (numbering, highlighting, navigation)
- [x] Color appears vibrant (not muted)
- [x] Theme switching (light/dark/sepia) maintains color
- [x] Entire preview row is tappable
- [x] Color picker dialog shows live preview
- [x] Color name displays correctly in Arabic

### Automated Testing

- **Unit Tests**: Test `PrimaryColorNotifier` provider behavior
- **Widget Tests**: Test color picker UI components
- **Integration Tests**: Test color persistence and theme generation

---

## Future Enhancements (Optional)

1. **Color History**: Save recently used colors for quick access
2. **Theme-Specific Colors**: Allow different colors for light/dark/sepia themes
3. **Color Presets Expansion**: Add more preset colors based on user feedback
4. **Accessibility Checks**: Warn users if selected color has poor contrast
5. **Color Import**: Allow importing colors from images or hex codes

---

## Related Files

### Core Implementation
- `lib/providers.dart` - PrimaryColorNotifier provider
- `lib/themes.dart` - Dynamic theme generation
- `lib/main.dart` - Theme integration
- `lib/constants.dart` - Color constants and presets

### UI Components
- `lib/screens/settings_screen.dart` - Color picker UI
- `lib/widgets/shared/leading_number_text.dart` - Numbering using primary color
- `lib/widgets/mushaf_line.dart` - Ayat highlighting using primary color

### Usage Points
- `lib/widgets/shared/app_bottom_navigation.dart`
- `lib/widgets/statistics_cards.dart`
- `lib/screens/search_screen.dart`
- `lib/widgets/bookmark_item_card.dart`
- `lib/widgets/countdown_circle.dart`

---

## Conclusion

The Primary Color Customization feature provides users with a comprehensive way to personalize their app experience. The implementation ensures vibrant, exact colors are applied throughout the app, with intuitive UI for both preset and custom color selection. The feature is fully functional, well-integrated, and provides a polished user experience.

**Status**: ✅ **COMPLETE AND OPERATIONAL**

