import 'package:flutter/material.dart';
import 'dart:math'; // For min()
import '../../constants.dart';
import '../../screens/settings_screen.dart';
import '../../screens/search_screen.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSearchPressed;
  final bool showBackButton;
  final Widget? trailing;

  const AppHeader({
    super.key,
    required this.title,
    this.onSearchPressed,
    this.showBackButton = false,
    this.trailing,
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
      child: Row(
        children: [
          // Search and Settings icons (left side)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!showBackButton)
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SettingsScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(-1.0, 0.0);
                              const end = Offset(0.0, 0.0);
                              const curve = Curves.easeInOut;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.settings,
                    size: kAppHeaderIconSize,
                    color: iconColor,
                  ),
                ),
              if (onSearchPressed != null)
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SearchScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(-1.0, 0.0);
                              const end = Offset(0.0, 0.0);
                              const curve = Curves.easeInOut;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.search,
                    size: kAppHeaderIconSize,
                    color: iconColor,
                  ),
                ),
            ],
          ),
          // Title
          Expanded(child: _buildTitleWithMixedFonts(title, theme, context)),
          // Optional trailing widget (e.g., Memorize toggle)
          if (trailing != null) trailing!,
          // Back button (if enabled) - comes after title for RTL
          if (showBackButton)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_forward_ios,
                size: kAppHeaderIconSize,
                color: iconColor,
              ),
            ),
        ],
      ),
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

      // Calculate responsive font sizes like in mushaf_page.dart
      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;
      final double widthScale = screenWidth / referenceScreenWidth;
      final double heightScale = screenHeight / referenceScreenHeight;
      final double scaleFactor = min(widthScale, heightScale);

      final double juzFontSize = 24 * scaleFactor; // Same as juzHizbStyle
      final double surahFontSize =
          28 * scaleFactor; // Same as surahNameHeaderStyle

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Juz glyph on the left
          if (parts.isNotEmpty && parts.first.text.contains('juz'))
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
          // Surah glyph on the right
          if (parts.length > 1 && parts[1].text.contains('surah'))
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
    return Text(
      title,
      textAlign: showBackButton ? TextAlign.right : TextAlign.left,
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
    } else if (title.contains('surah') || _containsArabicText(title)) {
      return surahNameFontFamily;
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
