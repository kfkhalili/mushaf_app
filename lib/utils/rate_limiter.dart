import 'package:flutter/foundation.dart';

/// WHY: Rate limiter utility to prevent DoS attacks and abuse.
///
/// Provides rate limiting functionality for search operations and other
/// potentially expensive operations that could be exploited.
class RateLimiter {
  final int _maxRequests;
  final Duration _window;
  final List<DateTime> _requestTimestamps = [];

  /// Creates a rate limiter.
  ///
  /// [maxRequests] - Maximum number of requests allowed in the time window
  /// [window] - Time window for rate limiting
  RateLimiter({required int maxRequests, required Duration window})
    : _maxRequests = maxRequests,
      _window = window;

  /// Checks if a request can be made.
  ///
  /// Returns `true` if the request is allowed, `false` if rate limit exceeded.
  bool canMakeRequest() {
    final now = DateTime.now();

    // Remove timestamps outside the window
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > _window,
    );

    // Check if we've exceeded the limit
    if (_requestTimestamps.length >= _maxRequests) {
      if (kDebugMode) {
        debugPrint(
          'Rate limit exceeded: $_maxRequests requests in ${_window.inSeconds}s',
        );
      }
      return false;
    }

    // Record this request
    _requestTimestamps.add(now);
    return true;
  }

  /// Resets the rate limiter (clears all recorded requests).
  void reset() {
    _requestTimestamps.clear();
  }

  /// Returns the number of requests remaining in the current window.
  int get remainingRequests {
    final now = DateTime.now();
    _requestTimestamps.removeWhere(
      (timestamp) => now.difference(timestamp) > _window,
    );
    return _maxRequests - _requestTimestamps.length;
  }
}

/// WHY: Pre-configured rate limiter for search operations.
///
/// Limits search requests to prevent DoS attacks while allowing normal usage.
class SearchRateLimiter {
  static final RateLimiter _instance = RateLimiter(
    maxRequests: 30, // Allow 30 searches per minute
    window: const Duration(minutes: 1),
  );

  /// Checks if a search request can be made.
  ///
  /// Returns `true` if the search is allowed, `false` if rate limit exceeded.
  static bool canMakeRequest() {
    return _instance.canMakeRequest();
  }

  /// Resets the search rate limiter.
  static void reset() {
    _instance.reset();
  }

  /// Returns the number of search requests remaining.
  static int get remainingRequests => _instance.remainingRequests;
}
