import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/utils/rate_limiter.dart';

void main() {
  group('RateLimiter', () {
    test('allows requests within limit', () {
      final limiter = RateLimiter(
        maxRequests: 5,
        window: const Duration(seconds: 1),
      );

      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
    });

    test('blocks requests exceeding limit', () {
      final limiter = RateLimiter(
        maxRequests: 3,
        window: const Duration(seconds: 1),
      );

      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isFalse); // Exceeds limit
    });

    test('resets after window expires', () async {
      final limiter = RateLimiter(
        maxRequests: 2,
        window: const Duration(milliseconds: 100),
      );

      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isFalse); // Exceeds limit

      // Wait for window to expire
      await Future.delayed(const Duration(milliseconds: 150));

      // Should allow requests again
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
    });

    test('reset clears all timestamps', () {
      final limiter = RateLimiter(
        maxRequests: 2,
        window: const Duration(seconds: 1),
      );

      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isFalse); // Exceeds limit

      limiter.reset();

      // Should allow requests again after reset
      expect(limiter.canMakeRequest(), isTrue);
      expect(limiter.canMakeRequest(), isTrue);
    });

    test('remainingRequests returns correct count', () {
      final limiter = RateLimiter(
        maxRequests: 5,
        window: const Duration(seconds: 1),
      );

      expect(limiter.remainingRequests, equals(5));
      limiter.canMakeRequest();
      expect(limiter.remainingRequests, equals(4));
      limiter.canMakeRequest();
      expect(limiter.remainingRequests, equals(3));
    });
  });

  group('SearchRateLimiter', () {
    test('allows search requests within limit', () {
      SearchRateLimiter.reset(); // Reset for clean test

      // Should allow multiple requests
      expect(SearchRateLimiter.canMakeRequest(), isTrue);
      expect(SearchRateLimiter.canMakeRequest(), isTrue);
      expect(SearchRateLimiter.canMakeRequest(), isTrue);
    });

    test('blocks search requests exceeding limit', () {
      SearchRateLimiter.reset(); // Reset for clean test

      // Make 30 requests (the limit)
      for (int i = 0; i < 30; i++) {
        final allowed = SearchRateLimiter.canMakeRequest();
        if (i < 30) {
          expect(allowed, isTrue, reason: 'Request $i should be allowed');
        }
      }

      // 31st request should be blocked
      expect(SearchRateLimiter.canMakeRequest(), isFalse);
    });

    test('remainingRequests returns correct count', () {
      SearchRateLimiter.reset(); // Reset for clean test

      final initial = SearchRateLimiter.remainingRequests;
      expect(initial, lessThanOrEqualTo(30));

      SearchRateLimiter.canMakeRequest();
      expect(SearchRateLimiter.remainingRequests, lessThan(initial));
    });
  });
}
