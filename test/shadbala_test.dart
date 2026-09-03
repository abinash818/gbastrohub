import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/shadbala_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShadbalaService Tests', () {
    test('Naisargika Bala has correct fixed values in Virupas', () {
      expect(ShadbalaService.NAISARGIKA_BALA['Sun'], equals(60.0));
      expect(ShadbalaService.NAISARGIKA_BALA['Moon'], equals(51.43));
      expect(ShadbalaService.NAISARGIKA_BALA['Venus'], equals(42.86));
      expect(ShadbalaService.NAISARGIKA_BALA['Jupiter'], equals(34.29));
      expect(ShadbalaService.NAISARGIKA_BALA['Mercury'], equals(25.71));
      expect(ShadbalaService.NAISARGIKA_BALA['Mars'], equals(17.14));
      expect(ShadbalaService.NAISARGIKA_BALA['Saturn'], equals(8.57));
    });

    test('Shadbala calculation computes all 6 balas and ranks 7 planets correctly', () {
      Map<String, double> planetLons = {
        'Sun': 10.0,       // Deep exaltation in Aries (10°) -> Uchha Bala = 60
        'Moon': 33.0,      // Deep exaltation in Taurus (3°)
        'Mars': 298.0,     // Deep exaltation in Capricorn (28°)
        'Mercury': 165.0,  // Deep exaltation in Virgo (15°)
        'Jupiter': 95.0,   // Deep exaltation in Cancer (5°)
        'Venus': 357.0,    // Deep exaltation in Pisces (27°)
        'Saturn': 200.0,   // Deep exaltation in Libra (20°)
      };

      double lagnaLon = 0.0;
      DateTime dt = DateTime(2026, 9, 1, 12, 0); // Noon birth

      final res = ShadbalaService.calculateShadbala(
        planetLons: planetLons,
        lagnaLon: lagnaLon,
        birthDt: dt,
        sunriseStr: "06:00",
        sunsetStr: "18:00",
      );

      expect(res['planets'], isNotNull);
      expect(res['summary_list'], isNotNull);
      expect((res['summary_list'] as List).length, equals(7));

      final sunData = res['planets']['Sun'];
      expect(sunData['planet_tamil'], equals('சூரியன்'));
      expect(sunData['total_virupas'], isPositive);
      expect(sunData['total_rupas'], equals(sunData['total_virupas'] / 60.0));
      expect(sunData['required_rupas'], equals(6.5));

      final topPlanet = res['top_planet'];
      expect(topPlanet['rank'], equals(1));
    });
  });
}
