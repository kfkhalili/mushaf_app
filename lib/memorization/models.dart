import 'package:flutter/foundation.dart';

@immutable
class MemorizationConfig {
  final int visibleWindowSize; // usually 3
  final double fadeStepPerTap; // e.g., 0.15
  final int tapsPerReveal; // fixed taps required before revealing next ayah
  final double revealThresholdNext; // when current <= 0.40
  final double
  revealThresholdSecondNext; // when current <= 0.70 and next <= 0.40

  const MemorizationConfig({
    this.visibleWindowSize = 3,
    this.fadeStepPerTap = 0.15,
    this.tapsPerReveal = 4,
    this.revealThresholdNext = 0.40,
    this.revealThresholdSecondNext = 0.70,
  });

  MemorizationConfig copyWith({
    int? visibleWindowSize,
    double? fadeStepPerTap,
    int? tapsPerReveal,
    double? revealThresholdNext,
    double? revealThresholdSecondNext,
  }) {
    return MemorizationConfig(
      visibleWindowSize: visibleWindowSize ?? this.visibleWindowSize,
      fadeStepPerTap: fadeStepPerTap ?? this.fadeStepPerTap,
      tapsPerReveal: tapsPerReveal ?? this.tapsPerReveal,
      revealThresholdNext: revealThresholdNext ?? this.revealThresholdNext,
      revealThresholdSecondNext:
          revealThresholdSecondNext ?? this.revealThresholdSecondNext,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemorizationConfig &&
          runtimeType == other.runtimeType &&
          visibleWindowSize == other.visibleWindowSize &&
          fadeStepPerTap == other.fadeStepPerTap &&
          tapsPerReveal == other.tapsPerReveal &&
          revealThresholdNext == other.revealThresholdNext &&
          revealThresholdSecondNext == other.revealThresholdSecondNext;

  @override
  int get hashCode => Object.hash(
    visibleWindowSize,
    fadeStepPerTap,
    tapsPerReveal,
    revealThresholdNext,
    revealThresholdSecondNext,
  );
}

@immutable
class AyahWindowState {
  final List<int> ayahIndices; // absolute indices within the page
  final List<double> opacities; // aligned 0.0–1.0 per ayah
  final List<int> tapsSinceReveal; // aligned counters

  const AyahWindowState({
    required this.ayahIndices,
    required this.opacities,
    required this.tapsSinceReveal,
  });

  AyahWindowState copyWith({
    List<int>? ayahIndices,
    List<double>? opacities,
    List<int>? tapsSinceReveal,
  }) {
    return AyahWindowState(
      ayahIndices: ayahIndices ?? this.ayahIndices,
      opacities: opacities ?? this.opacities,
      tapsSinceReveal: tapsSinceReveal ?? this.tapsSinceReveal,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahWindowState &&
          runtimeType == other.runtimeType &&
          listEquals(ayahIndices, other.ayahIndices) &&
          listEquals(opacities, other.opacities) &&
          listEquals(tapsSinceReveal, other.tapsSinceReveal);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(ayahIndices),
    Object.hashAll(opacities),
    Object.hashAll(tapsSinceReveal),
  );
}

@immutable
class MemorizationSessionState {
  final int pageNumber;
  final AyahWindowState window;
  final int lastAyahIndexShown; // absolute within page
  final DateTime lastUpdatedAt;
  final int passCount;

  const MemorizationSessionState({
    required this.pageNumber,
    required this.window,
    required this.lastAyahIndexShown,
    required this.lastUpdatedAt,
    required this.passCount,
  });

  MemorizationSessionState copyWith({
    int? pageNumber,
    AyahWindowState? window,
    int? lastAyahIndexShown,
    DateTime? lastUpdatedAt,
    int? passCount,
  }) {
    return MemorizationSessionState(
      pageNumber: pageNumber ?? this.pageNumber,
      window: window ?? this.window,
      lastAyahIndexShown: lastAyahIndexShown ?? this.lastAyahIndexShown,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      passCount: passCount ?? this.passCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemorizationSessionState &&
          runtimeType == other.runtimeType &&
          pageNumber == other.pageNumber &&
          window == other.window &&
          lastAyahIndexShown == other.lastAyahIndexShown &&
          lastUpdatedAt == other.lastUpdatedAt &&
          passCount == other.passCount;

  @override
  int get hashCode => Object.hash(
    pageNumber,
    window,
    lastAyahIndexShown,
    lastUpdatedAt,
    passCount,
  );
}
