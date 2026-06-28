import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/constants.dart';
import 'package:mushaf_app/utils/validation_helpers.dart';

void main() {
  group('validatePageNumber', () {
    test('accepts the first page', () {
      expect(() => validatePageNumber(1), returnsNormally);
    });

    test('rejects zero and negative pages', () {
      expect(() => validatePageNumber(0), throwsArgumentError);
      expect(() => validatePageNumber(-5), throwsArgumentError);
    });

    test('defaults to the generic ceiling for large layouts', () {
      // WHY: pages beyond Uthmani's 604 must no longer be rejected outright,
      // so the Indopak (849) and Indopak 9-line (1890) layouts work.
      expect(() => validatePageNumber(849), returnsNormally);
      expect(() => validatePageNumber(1890), returnsNormally);
      expect(() => validatePageNumber(maxSupportedPages), returnsNormally);
      expect(
        () => validatePageNumber(maxSupportedPages + 1),
        throwsArgumentError,
      );
    });

    test('honors a per-layout maxPage bound', () {
      expect(() => validatePageNumber(700, maxPage: 849), returnsNormally);
      expect(() => validatePageNumber(605, maxPage: 604), throwsArgumentError);
    });
  });
}
