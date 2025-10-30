## Git Hooks (Local Safety Nets)

Install local hooks to block bad commits/pushes:

```bash
bash scripts/install-hooks.sh
```

What runs on each hook:
- pre-commit: `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos`, `flutter test -r expanded`
- pre-push: same checks before pushing

If any step fails, the commit/push is aborted.

# mushaf_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
