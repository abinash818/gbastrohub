import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/vaasthu_service.dart';

void main() {
  group('VaasthuService / Kuzhikanakku Tests', () {
    test('Calculates accurate Kuzhi and Poruthams for 1000 sqft', () {
      final res = VaasthuService.evaluateManaiyadiBySqft(1000);
      // kuzhi = round(1000 / 9 * 10) / 10 = 111.1
      expect(res.kuzhi, equals(111.1));
      expect(res.details.length, equals(11));
    });

    test('Dimension evaluation calculates correct area and good feet', () {
      final res = VaasthuService.evaluateManaiyadi(20, 0, 30, 0);
      expect(res.sqft, equals(600.0));
      // 600 / 9 = 66.666 -> 66.7 kuzhi
      expect(res.kuzhi, equals(66.7));
      expect(res.details.any((d) => d.nameTa.contains("உள்பக்க அகலம்")), isTrue);
      expect(res.details.any((d) => d.nameTa.contains("உள்பக்க நீளம்")), isTrue);
    });

    test('Good lengths suggestions returns results for 16ft width', () {
      final suggestions = VaasthuService.findGoodLengths(16, 0);
      expect(suggestions.isNotEmpty, isTrue);
      for (final s in suggestions) {
        expect(s.result.manaiGood, isTrue);
        expect(s.result.goodCount, greaterThanOrEqualTo(7));
      }
    });

    test('Best areas explorer filters and sorts correctly', () {
      final allBest = VaasthuService.findBestAreas();
      expect(allBest.isNotEmpty, isTrue);
      for (final a in allBest) {
        expect(a.manaiGood, isTrue);
        expect(a.goodCount, greaterThanOrEqualTo(8));
      }

      final karudaBest = VaasthuService.findBestAreas(manaiFilter: 'Karuda');
      for (final a in karudaBest) {
        expect(a.manaiName.contains('Karuda'), isTrue);
      }
    });
  });
}
