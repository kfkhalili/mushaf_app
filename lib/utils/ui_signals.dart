import 'package:flutter/foundation.dart';
import 'dart:async';

// Global UI signal notifiers for lightweight cross-widget communication

// Trigger a small animation on memorization toggle icon when user attempts
// to scroll while memorization mode is active.
final ValueNotifier<int> memorizationIconFlashTick = ValueNotifier<int>(0);

Future<void> flashMemorizationIcon({
  int times = 3,
  Duration interval = const Duration(milliseconds: 120),
}) async {
  for (int i = 0; i < times; i++) {
    memorizationIconFlashTick.value = memorizationIconFlashTick.value + 1;
    if (i < times - 1) {
      await Future.delayed(interval);
    }
  }
}
