import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// The result of applying a memorization tap: whether the reader has finished
/// the current page (last ayah revealed and faded away) and should advance to
/// the next page, or stay on the current one.
enum MemorizationTapOutcome { stay, advanceToNextPage }

@immutable
class MemorizationConfig extends Equatable {
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
  List<Object?> get props => [
    visibleWindowSize,
    fadeStepPerTap,
    tapsPerReveal,
    revealThresholdNext,
    revealThresholdSecondNext,
  ];
}

@immutable
class AyahWindowState extends Equatable {
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
  List<Object?> get props => [ayahIndices, opacities, tapsSinceReveal];
}

@immutable
class MemorizationSessionState extends Equatable {
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
  List<Object?> get props => [
    pageNumber,
    window,
    lastAyahIndexShown,
    lastUpdatedAt,
    passCount,
  ];
}
