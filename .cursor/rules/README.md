# Cursor Rules for Mushaf App

This directory contains Cursor AI rules that help with development by providing context-aware guidance based on the codebase patterns and conventions.

## Available Rules

### 1. **project-architecture.mdc** ✨ Always Applied

Overview of the entire project structure, directory organization, and key architectural patterns. This rule provides context for how the Mushaf app is organized.

**Key Topics:**

- Project structure and entry points
- Directory organization (`screens/`, `widgets/`, `services/`, etc.)
- Core architecture patterns
- Multi-platform support

---

### 2. **riverpod-state-management.mdc** 📦 Dart Files

Comprehensive guide to Riverpod state management patterns using code generation (v3.0+).

**Key Topics:**

- Provider declaration patterns (`@Riverpod`, `@riverpod`)
- Stateful notifier pattern
- Async provider patterns
- Code generation commands
- Consumer widget patterns
- Legacy StateNotifier usage

---

### 3. **database-patterns.mdc** 🗄️ On-Demand

Database service patterns and SQLite conventions specific to this app's multi-database architecture.

**Key Topics:**

- Multiple database files and their purposes
- Initialization patterns with guards
- `DbConstants` usage for type-safe queries
- Safe parsing and error handling
- Caching patterns for performance
- Query patterns and best practices

---

### 4. **widget-conventions.mdc** 🎨 Widget Files

Widget structure and UI component conventions for building consistent interfaces.

**Key Topics:**

- Widget hierarchy (Screens vs Widgets)
- ConsumerWidget and ConsumerStatefulWidget patterns
- Responsive sizing calculations
- RTL (Right-to-Left) layout support
- AsyncValue handling
- Immutability and key usage

---

### 5. **constants-and-organization.mdc** 📋 On-Demand

Constants usage and code organization patterns, emphasizing the centralized constants file.

**Key Topics:**

- Database constants (`DbConstants` class)
- Font constants
- App configuration (604 pages, etc.)
- Responsive design constants
- Styling constants
- Code organization rules
- WHY comments pattern

---

### 6. **theming-patterns.mdc** 🎨 On-Demand

Theme management covering light, dark, and sepia themes with persistence.

**Key Topics:**

- Three theme definitions
- Theme state management
- Theme persistence with SharedPreferences
- Sepia theme special handling
- System overlay styles
- Theme-aware color usage

---

### 7. **dart-flutter-conventions.mdc** 📱 Dart Files

General Dart and Flutter best practices and conventions used throughout the codebase.

**Key Topics:**

- Null safety patterns
- Immutability and equality implementation
- Async patterns
- Error handling
- Collection usage
- Method organization
- Documentation standards
- Package dependencies

---

### 8. **assets-and-fonts.mdc** 🔤 On-Demand

Asset management and the unique page-specific font loading system (604 fonts!).

**Key Topics:**

- Asset structure (databases, fonts)
- 604 page-specific fonts
- Dynamic font loading pattern
- Font naming conventions
- Basmallah and Surah name rendering
- Font size scaling
- Database copying pattern

---

### 9. **commit-conventions.mdc** 📝 Always Applied

Commit message conventions following the [Conventional Commits specification](https://www.conventionalcommits.org/en/v1.0.0/).

**Key Topics:**

- Commit message structure (`<type>[scope]: <description>`)
- Required types (`feat:`, `fix:`)
- Additional types (`build:`, `chore:`, `docs:`, etc.)
- Breaking change notation (`BREAKING CHANGE:` or `!`)
- Commit message examples and guidelines
- Benefits for automated tooling

---

### 10. **functional-programming.mdc** 🔄 Always Applied

Functional programming paradigms, constructs, and structures to be used whenever possible.

**Key Topics:**

- Immutability principles and `@immutable` usage
- Pure functions and avoiding side effects
- Higher-order functions (map, filter, reduce)
- Functional collection operations
- Async functional patterns
- Widget composition over inheritance
- Functional error handling with Result types
- Performance considerations (lazy evaluation, memoization)
- When NOT to use functional programming

---

## Rule Activation

- **Always Applied**: Applied to every AI request automatically
- **Dart Files**: Applied when working with `*.dart` files
- **Widget Files**: Applied when working with files in `lib/widgets/**` or `lib/screens/**`
- **On-Demand**: Activated by description matching or manual selection

## Quick Reference

### Key Files Referenced

- `lib/main.dart` - App entry point
- `lib/models.dart` - Data models
- `lib/constants.dart` - All app constants
- `lib/providers.dart` - Riverpod providers
- `lib/themes.dart` - Theme definitions
- `lib/services/database_service.dart` - Database operations
- `lib/services/font_service.dart` - Font loading
- `pubspec.yaml` - Dependencies and assets

### Important Constants

- Total Quran pages: `604`
- Database files: `5` (layout, script, surah, juz, hizb)
- Page-specific fonts: `604` (one per page)
- Supported themes: `3` (light, dark, sepia)
- Default orientation: Portrait only

### Code Generation

After modifying providers:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Contributing to Rules

When adding or modifying rules:

1. Use `.mdc` file extension
2. Include frontmatter with appropriate metadata
3. Reference files using `[filename](mdc:path/to/file)` syntax
4. Keep rules focused on specific aspects
5. Use code examples to illustrate patterns
6. Update this README with new rules

## Rule Metadata Options

```yaml
---
alwaysApply: true          # Applied to every request
description: "..."         # AI fetches rule based on description
globs: *.dart,*.tsx        # Applied to matching file patterns
---
```

Only one metadata type is typically set (though globs + description is valid).
