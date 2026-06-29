import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps [screen] inside the app's standard test shell: a [ProviderScope] with
/// [overrides], a [MaterialApp], and the right-to-left [Directionality] that
/// every screen inherits in production (see CLAUDE.md — the app wraps its tree
/// in `Directionality(TextDirection.rtl)`).
///
/// WHY: 62 widget tests hand-rolled `ProviderScope(child: MaterialApp(...))`
/// inline, none of them wrapped the subject in RTL (so RTL layout bugs could
/// not surface), and the `overrides` list carried an `// ignore:` on every
/// site. One shell, one place for the RTL wrap and the override typing.
///
/// [overrides] is typed `dynamic` because Riverpod 3's `Override` type is
/// `part` of the framework's internals and not publicly nameable. Callers pass
/// a normal list literal of `provider.overrideWith(...)` results, whose runtime
/// type is `List<Override>` and so assigns cleanly; the default is an empty
/// `List<Never>`, a subtype of `List<Override>`.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  // ignore: avoid_annotating_with_dynamic
  dynamic overrides = const <Never>[],
  Map<String, Object>? prefs,
}) async {
  if (prefs != null) {
    SharedPreferences.setMockInitialValues(prefs);
  }
  // WHY: mount only — no trailing pump. The first frame (built by pumpWidget)
  // is the loading state, so a test can assert on it before advancing with
  // [settle] or [pumpUntilFound]. Pumping here would resolve `Future.value`
  // overrides and lose that state.
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Directionality(textDirection: TextDirection.rtl, child: screen),
      ),
    ),
  );
}

/// Pumps the widget tree in fixed [step]s until [finder] matches at least one
/// widget, then returns. Throws a [TestFailure] if [finder] never matches
/// within [timeout].
///
/// WHY: `pumpAndSettle()` never settles in this app — the PageView controller
/// and async data providers keep scheduling frames — so tests had grown 48
/// hand-rolled `for (i…) pump(200ms)` loops with drifting magic counts, and 7
/// of them then guarded their assertions with `if (finder.evaluate().isNotEmpty)`,
/// which silently passes when the data never loads. This helper replaces both:
/// it waits for a concrete condition and *fails* when the condition is never
/// met, so a test can no longer pass by asserting nothing.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
  Duration step = const Duration(milliseconds: 100),
}) async {
  // WHY: clamp the step so a zero/negative step can't divide by zero here.
  final int stepMs = step.inMilliseconds < 1 ? 1 : step.inMilliseconds;
  final Duration stepDuration = Duration(milliseconds: stepMs);
  final int maxSteps = (timeout.inMilliseconds / stepMs).ceil();
  for (int i = 0; i < maxSteps; i++) {
    await tester.pump(stepDuration);
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure(
    'pumpUntilFound: $finder not found within ${timeout.inMilliseconds}ms',
  );
}

/// Pumps the tree for a fixed budget so animations and async providers can
/// advance, without asserting on any particular widget. Prefer [pumpUntilFound]
/// whenever there is a concrete thing to wait for; reach for this only when
/// settling the frame is the whole point (e.g. immediately before a golden
/// capture).
Future<void> settle(
  WidgetTester tester, {
  Duration duration = const Duration(seconds: 2),
  Duration step = const Duration(milliseconds: 100),
}) async {
  // WHY: clamp the step so a zero/negative step can't divide by zero here.
  final int stepMs = step.inMilliseconds < 1 ? 1 : step.inMilliseconds;
  final Duration stepDuration = Duration(milliseconds: stepMs);
  final int steps = (duration.inMilliseconds / stepMs).ceil();
  for (int i = 0; i < steps; i++) {
    await tester.pump(stepDuration);
  }
}
