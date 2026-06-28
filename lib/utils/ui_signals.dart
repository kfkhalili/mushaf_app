// The memorization icon "flash" signal moved out of this global ValueNotifier
// and into a Riverpod provider: `memorizationIconFlashProvider` in
// `lib/providers.dart` (call `.flash()` / `.pulse()` on its notifier, and
// `ref.watch` it to animate). This file is intentionally left empty and can be
// deleted.
