import 'package:flutter/foundation.dart';

@immutable
class MemorizationConfig {
  final int visibleWindowSize; // usually 3 (previous, current, next)
  final bool startWithTextHidden; // default: true
  final bool autoAdvanceAfterGrade; // default: true
  final int masteryLevels; // 3 levels (Easy=3, Medium=2, Hard=1)

  const MemorizationConfig({
    this.visibleWindowSize = 3,
    this.startWithTextHidden = true,
    this.autoAdvanceAfterGrade = true,
    this.masteryLevels = 3,
  });

  MemorizationConfig copyWith({
    int? visibleWindowSize,
    bool? startWithTextHidden,
    bool? autoAdvanceAfterGrade,
    int? masteryLevels,
  }) {
    return MemorizationConfig(
      visibleWindowSize: visibleWindowSize ?? this.visibleWindowSize,
      startWithTextHidden: startWithTextHidden ?? this.startWithTextHidden,
      autoAdvanceAfterGrade: autoAdvanceAfterGrade ?? this.autoAdvanceAfterGrade,
      masteryLevels: masteryLevels ?? this.masteryLevels,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemorizationConfig &&
          runtimeType == other.runtimeType &&
          visibleWindowSize == other.visibleWindowSize &&
          startWithTextHidden == other.startWithTextHidden &&
          autoAdvanceAfterGrade == other.autoAdvanceAfterGrade &&
          masteryLevels == other.masteryLevels;

  @override
  int get hashCode => Object.hash(
        visibleWindowSize,
        startWithTextHidden,
        autoAdvanceAfterGrade,
        masteryLevels,
      );
}

@immutable
class AyahWindowState {
  final List<int> ayahIndices; // absolute indices within the page
  final List<bool> isHidden; // aligned boolean - true if hidden, false if visible
  final List<int> masteryLevel; // aligned mastery levels: 0 (not reviewed), 1 (hard), 2 (medium), 3 (easy)
  final List<int> reviewCount; // aligned count of how many times reviewed

  const AyahWindowState({
    required this.ayahIndices,
    required this.isHidden,
    required this.masteryLevel,
    required this.reviewCount,
  });

  AyahWindowState copyWith({
    List<int>? ayahIndices,
    List<bool>? isHidden,
    List<int>? masteryLevel,
    List<int>? reviewCount,
  }) {
    return AyahWindowState(
      ayahIndices: ayahIndices ?? this.ayahIndices,
      isHidden: isHidden ?? this.isHidden,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahWindowState &&
          runtimeType == other.runtimeType &&
          listEquals(ayahIndices, other.ayahIndices) &&
          listEquals(isHidden, other.isHidden) &&
          listEquals(masteryLevel, other.masteryLevel) &&
          listEquals(reviewCount, other.reviewCount);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(ayahIndices),
    Object.hashAll(isHidden),
    Object.hashAll(masteryLevel),
    Object.hashAll(reviewCount),
  );
}

@immutable
class MemorizationSessionState {
  final int pageNumber;
  final AyahWindowState window;
  final int currentAyahIndex; // Currently focused ayah (for hide/reveal)
  final DateTime lastUpdatedAt;
  final int totalPasses; // Total times page has been reviewed (not "completed")

  const MemorizationSessionState({
    required this.pageNumber,
    required this.window,
    required this.currentAyahIndex,
    required this.lastUpdatedAt,
    required this.totalPasses,
  });

  MemorizationSessionState copyWith({
    int? pageNumber,
    AyahWindowState? window,
    int? currentAyahIndex,
    DateTime? lastUpdatedAt,
    int? totalPasses,
  }) {
    return MemorizationSessionState(
      pageNumber: pageNumber ?? this.pageNumber,
      window: window ?? this.window,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      totalPasses: totalPasses ?? this.totalPasses,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemorizationSessionState &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          window == other.window &&
          currentAyahIndex == other.currentAyahIndex &&
          lastUpdatedAt == other.lastUpdatedAt &&
          totalPasses == other.totalPasses;

  @override
  int get hashCode => Object.hash(
    pageNumber,
    window,
    currentAyahIndex,
    lastUpdatedAt,
    totalPasses,
  );
}
