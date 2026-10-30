import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/astro_engine/astro_engine.dart';
import 'package:astrology_flutter/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Compare sunrise for Namakkal vs Trichy vs Chennai', () async {
    await KPService.init();
    final engine = AstroEngine();
    final int ayanamsaMode = await SettingsService.getAyanamsa();

    final testDates = [
      DateTime(2026, 4, 23),
      DateTime(2026, 6, 4),
      DateTime(2026, 7, 27),
      DateTime(2026, 8, 22),
      DateTime(2026, 10, 28),
      DateTime(2026, 11, 24),
      DateTime(2026, 1, 26),
      DateTime(2026, 3, 6),
    ];

    final cities = {
      'நாமக்கல்': {'lat': 11.2189, 'lon': 78.1674},
      'திருச்சி': {'lat': 10.7905, 'lon': 78.7047},
      'சென்னை': {'lat': 13.0827, 'lon': 80.2707},
    };

    for (var date in testDates) {
      print('\n--- Date: ${date.toIso8601String().substring(0, 10)} ---');
      for (var entry in cities.entries) {
        final lat = entry.value['lat']!;
        final lon = entry.value['lon']!;
        final localMidnight = DateTime(date.year, date.month, date.day, 0, 0, 0);
        final utcMidnight = localMidnight.subtract(Duration(minutes: (5.5 * 60).round()));

        double jdMidnight = engine.calculate(utcMidnight, lat, lon, ayanamsaMode: ayanamsaMode).jd;
        var phen = await engine.calcPhenomena(jdMidnight, lat, lon, 0);
        double riseJD = phen['rise'] ?? (jdMidnight + 0.25);
        String s = KPService.formatJDToLocalTime(riseJD, 5.5, includeSeconds: true);
        print('${entry.key}: Sunrise = $s');
      }
    }
  });
}

