import 'package:flutter/foundation.dart';

// Global UI signal notifiers for lightweight cross-widget communication

// Trigger a small animation on memorization toggle icon when user attempts
// to scroll while memorization mode is active.
final ValueNotifier<int> memorizationIconFlashTick = ValueNotifier<int>(0);


