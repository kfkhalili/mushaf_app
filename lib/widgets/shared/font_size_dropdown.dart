import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants.dart';
import '../../providers.dart';

class FontSizeDropdown extends ConsumerWidget {
  const FontSizeDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFontSize = ref.watch(fontSizeSettingProvider);
    final currentLayout = ref.watch(mushafLayoutSettingProvider);
    final theme = Theme.of(context);

    // Get layout-specific font size options
    final fontSizeOptions =
        layoutFontSizeOptions[currentLayout] ?? [16.0, 18.0, 20.0];

    return DropdownButtonFormField<double>(
      isExpanded: true,
      initialValue: currentFontSize,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      selectedItemBuilder: (BuildContext context) {
        return fontSizeOptions.map<Widget>((double fontSize) {
          return Text(
            fontSizeLabels[fontSize] ?? fontSize.toString(),
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
      items: fontSizeOptions.map((fontSize) {
        return DropdownMenuItem<double>(
          value: fontSize,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              fontSizeLabels[fontSize] ?? fontSize.toString(),
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              fontPreviewText,
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: quranCommonFontFamily,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      onChanged: (double? fontSize) {
        if (fontSize != null) {
          ref.read(fontSizeSettingProvider.notifier).setFontSize(fontSize);
        }
      },
    );
  }
}
