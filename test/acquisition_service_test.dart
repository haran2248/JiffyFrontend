import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/core/services/acquisition_service.dart';

void main() {
  group('AcquisitionService.parseReferrerToSource', () {
    test('maps facebook utm_source to META_ANDROID', () {
      expect(
        AcquisitionService.parseReferrerToSource(
            'utm_source=facebook&utm_medium=cpc&utm_campaign=summer'),
        'META_ANDROID',
      );
    });

    test('maps instagram utm_source to META_ANDROID', () {
      expect(
        AcquisitionService.parseReferrerToSource('utm_source=instagram_ad'),
        'META_ANDROID',
      );
    });

    test('maps custom valid utm_source to uppercase', () {
      expect(
        AcquisitionService.parseReferrerToSource('utm_source=testcode'),
        'TESTCODE',
      );
      expect(
        AcquisitionService.parseReferrerToSource('utm_source=CAMP_2026_XYZ'),
        'CAMP_2026_XYZ',
      );
    });

    test('handles url-encoded referrer query string', () {
      expect(
        AcquisitionService.parseReferrerToSource('utm_source%3DTESTCODE'),
        'TESTCODE',
      );
    });

    test('ignores google-play, organic, and (not set)', () {
      expect(
        AcquisitionService.parseReferrerToSource('utm_source=google-play'),
        isNull,
      );
      expect(
        AcquisitionService.parseReferrerToSource('utm_source=organic'),
        isNull,
      );
      expect(
        AcquisitionService.parseReferrerToSource('utm_source=(not set)'),
        isNull,
      );
    });

    test('ignores invalid length or characters', () {
      // Too short (< 3 chars)
      expect(AcquisitionService.parseReferrerToSource('utm_source=AB'), isNull);
      // Special characters not matching ^[A-Za-z0-9_]{3,40}$
      expect(
        AcquisitionService.parseReferrerToSource('utm_source=code-with-dashes!'),
        isNull,
      );
      // Empty
      expect(AcquisitionService.parseReferrerToSource(''), isNull);
      expect(AcquisitionService.parseReferrerToSource('utm_medium=cpc'), isNull);
    });
  });

  group('AcquisitionService.sourceRegex', () {
    test('validates 3 to 40 uppercase alphanumerics and underscores', () {
      expect(AcquisitionService.sourceRegex.hasMatch('ABC'), isTrue);
      expect(AcquisitionService.sourceRegex.hasMatch('TEST_CODE_123'), isTrue);
      expect(AcquisitionService.sourceRegex.hasMatch('AB'), isFalse);
      expect(AcquisitionService.sourceRegex.hasMatch('abc'), isFalse);
      expect(AcquisitionService.sourceRegex.hasMatch('INVALID-CODE'), isFalse);
      expect(AcquisitionService.sourceRegex.hasMatch('A' * 41), isFalse);
    });
  });
}
