import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../screens/settings_screen.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSearchPressed;
  final bool showBackButton;

  const AppHeader({
    super.key,
    required this.title,
    this.onSearchPressed,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                              const begin = Offset(1.0, 0.0);
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
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              if (onSearchPressed != null)
                IconButton(
                  onPressed: onSearchPressed,
                  icon: Icon(
                    Icons.search,
                    size: kAppHeaderIconSize,
                    color: theme.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
            ],
          ),
          // Title
          Expanded(
            child: Text(
              title,
              textAlign: showBackButton ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontSize: kAppHeaderTitleFontSize,
                fontWeight: FontWeight.w600,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
          // Back button (if enabled) - comes after title for RTL
          if (showBackButton)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_forward_ios,
                size: kAppHeaderIconSize,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
        ],
      ),
    );
  }
}
