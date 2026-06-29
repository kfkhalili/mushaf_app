import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// WHY: Golden tests render with sub-pixel / antialiasing differences across
/// environments — CI runner image patches, macOS version, and font hinting each
/// shift a handful of pixels even when nothing visually changed (observed as
/// "Pixel test failed, 0.00%, 5px diff" on CI while the same goldens pass
/// locally and passed on prior CI runs). The default comparator demands an
/// exact match, turning that noise into a red build.
///
/// Allow a small per-image pixel-difference tolerance so genuine visual
/// regressions (which produce far larger diffs) are still caught, while
/// environment noise is ignored. This config lives under test/golden/ so the
/// tolerant comparator applies only to golden tests.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final GoldenFileComparator current = goldenFileComparator;
  if (current is LocalFileComparator) {
    // WHY: reuse the framework's basedir so golden paths resolve exactly as
    // before; only the comparison tolerance changes.
    goldenFileComparator = _TolerantGoldenComparator(current.basedir);
  }
  await testMain();
}

/// A [LocalFileComparator] that passes when at most [_kTolerance] of the pixels
/// differ, instead of requiring a byte-exact match.
class _TolerantGoldenComparator extends LocalFileComparator {
  _TolerantGoldenComparator(Uri basedir)
    : super(basedir.resolve('flutter_test_config.dart'));

  /// Max fraction of differing pixels tolerated (0.5%). Environment noise is
  /// well under this; real UI regressions are well above it.
  static const double _kTolerance = 0.005;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _kTolerance) {
      return true;
    }
    final String error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
