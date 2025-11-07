import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../utils/responsive.dart';
import '../../utils/navigation.dart';
import '../../screens/settings_screen.dart';
import '../../screens/search_screen.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onExplorePressed;
  final bool showBackButton;
  final Widget? trailing;
  final bool
  titleOnRight; // When true, title appears on right (start of RTL), icons on left (end of RTL)

  const AppHeader({
    super.key,
    required this.title,
    this.onSearchPressed,
    this.onBookmarkPressed,
    this.onExplorePressed,
    this.showBackButton = false,
    this.trailing,
    this.titleOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color iconColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    return Container(
      height: kAppHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
      ),
      child: titleOnRight
          ? _buildReversedLayout(context, theme, iconColor)
          : _buildNormalLayout(context, theme, iconColor),
    );
  }

  Widget _buildNormalLayout(
    BuildContext context,
    ThemeData theme,
    Color iconColor,
  ) {
    return Row(
      children: [
        // Right side: Back button OR Search and Settings icons
        if (showBackButton)
          // Back button - appears on the right in RTL
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.chevron_left,
              size: kAppHeaderIconSize,
              color: iconColor,
            ),
          )
        else
        // Explore and Bookmark icons - appear on the right in RTL when no back button
        if (trailing == null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onBookmarkPressed != null)
                IconButton(
                  tooltip: 'العلامات المرجعية',
                  onPressed: onBookmarkPressed,
                  icon: Icon(
                    Icons.bookmark,
                    size: kAppHeaderIconSize,
                    color: iconColor,
                  ),
                ),
              if (onExplorePressed != null)
                IconButton(
                  tooltip: 'استكشاف المواضيع',
                  onPressed: onExplorePressed,
                  icon: Icon(
                    Icons.explore_outlined,
                    size: kAppHeaderIconSize,
                    color: iconColor,
                  ),
                ),
            ],
          ),
        // Spacing between right side icons and title
        if (showBackButton) const SizedBox(width: 8),
        // Title
        Expanded(child: _buildTitleWithMixedFonts(title, theme, context)),
        // Explore icon (only if back button is shown and explore is enabled)
        if (showBackButton && onExplorePressed != null && trailing == null)
          IconButton(
            tooltip: 'استكشاف المواضيع',
            onPressed: onExplorePressed,
            icon: Icon(
              Icons.explore_outlined,
              size: kAppHeaderIconSize,
              color: iconColor,
            ),
          ),
        // Search icon (before settings icon in RTL)
        if (onSearchPressed != null && trailing == null)
          IconButton(
            onPressed: () {
              pushSlideFromRight(context, const SearchScreen());
            },
            icon: Icon(
              Icons.search,
              size: kAppHeaderIconSize,
              color: iconColor,
            ),
          ),
        // Settings icon for Selection Screen (left side, separated from Bookmark/Search)
        if (trailing == null)
          IconButton(
            tooltip: 'الإعدادات',
            onPressed: () {
              pushSlideFromRight(context, const SettingsScreen());
            },
            icon: Icon(
              Icons.settings,
              size: kAppHeaderIconSize,
              color: iconColor,
            ),
          ),
        // Optional trailing widget
        if (trailing != null) trailing!,
      ],
    );
  }

  Widget _buildReversedLayout(
    BuildContext context,
    ThemeData theme,
    Color iconColor,
  ) {
    return Row(
      children: [
        // Title on the right (start of RTL Row) - expanded to fill available space
        Expanded(child: _buildTitleWithMixedFonts(title, theme, context)),
        // Icons on the left (end of RTL Row): Search and Settings
        if (trailing == null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onSearchPressed != null)
                IconButton(
                  tooltip: 'البحث',
                  onPressed: () {
                    pushSlideFromRight(context, const SearchScreen());
                  },
                  icon: Icon(
                    Icons.search,
                    size: kAppHeaderIconSize,
                    color: iconColor,
                  ),
                ),
              // Settings icon
              IconButton(
                tooltip: 'الإعدادات',
                onPressed: () {
                  pushSlideFromRight(context, const SettingsScreen());
                },
                icon: Icon(
                  Icons.settings,
                  size: kAppHeaderIconSize,
                  color: iconColor,
                ),
              ),
            ],
          ),
        // Optional trailing widget
        if (trailing != null) trailing!,
      ],
    );
  }

  Widget _buildTitleWithMixedFonts(
    String title,
    ThemeData theme,
    BuildContext context,
  ) {
    // Check if we have mixed content (juz + surah glyphs, or glyphs + Arabic)
    if ((title.contains('juz') && title.contains('surah')) ||
        (title.contains('juz') && _containsArabicText(title))) {
      // Split the title into parts
      final parts = _splitTitleIntoParts(title);

      final metrics = ResponsiveMetrics.of(context);
      final double scaleFactor = metrics.scaleFactor;

      final double juzFontSize = 24 * scaleFactor; // Same as juzHizbStyle
      final double surahFontSize =
          28 * scaleFactor; // Same as surahNameHeaderStyle

      // Find juz and surah parts dynamically
      _TitlePart? juzPart;
      _TitlePart? surahPart;
      for (final part in parts) {
        if (part.text.contains('juz')) {
          juzPart = part;
        } else if (part.text.contains('surah')) {
          surahPart = part;
        }
      }

      // Only render special layout if we have both parts
      if (juzPart != null && surahPart != null) {
        // Dart knows these are not null after the check above
        final juz = juzPart;
        final surah = surahPart;
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Surah glyph on the right (visual right, first in RTL Row) - right-aligned
            Text(
              surah.text,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: surahFontSize,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                fontFamily: surah.fontFamily,
              ),
            ),
            // Juz glyph on the left (visual left, second in RTL Row) - left-aligned
            Text(
              juz.text,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: juzFontSize,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                fontFamily: juz.fontFamily,
              ),
            ),
          ],
        );
      }

      // Fallback: render single part or original layout
      if (juzPart != null) {
        return Text(
          juzPart.text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: juzFontSize,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
            fontFamily: juzPart.fontFamily,
          ),
        );
      }

      if (surahPart != null) {
        return Text(
          surahPart.text,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: surahFontSize,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
            fontFamily: surahPart.fontFamily,
          ),
        );
      }

      // Fallback to original parts-based rendering
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (parts.isNotEmpty)
            Text(
              parts.first.text,
              style: TextStyle(
                fontSize: juzFontSize,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                fontFamily: parts.first.fontFamily,
              ),
            )
          else
            const SizedBox.shrink(),
          if (parts.length > 1)
            Text(
              parts[1].text,
              style: TextStyle(
                fontSize: surahFontSize,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
                fontFamily: parts[1].fontFamily,
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      );
    }

    // For single-font content, use the original approach
    // WHY: RTL titles should always align right, especially when back button is shown
    return Text(
      title,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontSize: kAppHeaderTitleFontSize,
        fontWeight: FontWeight.w600,
        color: theme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
        fontFamily: _getFontFamilyForTitle(title),
      ),
    );
  }

  List<_TitlePart> _splitTitleIntoParts(String title) {
    final List<_TitlePart> parts = [];

    // Split by spaces and process each part
    final words = title.split(' ');
    String currentText = '';
    String? currentFont;

    for (final word in words) {
      String? fontForWord;

      if (word.contains('juz')) {
        fontForWord = quranCommonFontFamily;
      } else if (word.contains('surah') || _containsArabicText(word)) {
        fontForWord = surahNameFontFamily;
      }

      if (currentFont != fontForWord) {
        // Font changed, add current part and start new one
        if (currentText.isNotEmpty) {
          parts.add(_TitlePart(currentText.trim(), currentFont));
        }
        currentText = word;
        currentFont = fontForWord;
      } else {
        // Same font, append to current text
        currentText += ' $word';
      }
    }

    // Add the last part
    if (currentText.isNotEmpty) {
      parts.add(_TitlePart(currentText.trim(), currentFont));
    }

    return parts;
  }

  String? _getFontFamilyForTitle(String title) {
    // Check if the title contains glyph strings
    if (title.contains('juz')) {
      return quranCommonFontFamily;
    } else if (title.contains('surah')) {
      return surahNameFontFamily;
    } else if (_containsArabicText(title)) {
      // WHY: Use IBMPlexSansArabic for Arabic text as per user's standard font
      return 'IBMPlexSansArabic';
    }
    return null; // Use default font for regular text
  }

  bool _containsArabicText(String text) {
    // Check if the text contains Arabic characters
    // Arabic Unicode range: U+0600 to U+06FF
    return text.runes.any((rune) => rune >= 0x0600 && rune <= 0x06FF);
  }
}

class _TitlePart {
  final String text;
  final String? fontFamily;

  _TitlePart(this.text, this.fontFamily);
}
