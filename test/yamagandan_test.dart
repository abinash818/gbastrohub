import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';

void main() {
  const List<String> tamilRasis = [
    "மேஷம்", "ரிஷபம்", "மிதுனம்", "கடகம்",
    "சிம்மம்", "கன்னி", "துலாம்", "விருச்சிகம்",
    "தனுசு", "மகரம்", "கும்பம்", "மீனம்"
  ];

  group('Yamagandan SubPlanet Degree Validation Tests', () {
    test('User Example 1: 31/10/2026 11:28 AM (Saturday Day / சனிக்கிழமை பகல்)', () {
      // 31/10/26 | NKL | 11.28 AM | சனிக்கிழமை
      // சூரி பாகை (துலாம்) = 13.35
      // சனி. எ. பாகை = 132.00
      // கூட்டுத்தொகை = 145.35
      // சூரி துலாம் 30 ... மகரம் வரை 120, மீதி கும்பம் = 25.35 எம பாகை
      final dt = DateTime(2026, 10, 31, 11, 28, 0);
      final sunrise = DateTime(2026, 10, 31, 6, 8, 0);
      final sunset = DateTime(2026, 10, 31, 17, 52, 0);
      // Thulam is index 6 (180° to 210°). Lon = 180 + 13.35 = 193.35
      const double sunLon = 180.0 + 13.35;

      final res = calculateAllJamakkolSubPlanets(
        currentTime: dt,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: sunrise.add(const Duration(days: 1)),
        prevSunset: sunset.subtract(const Duration(days: 1)),
        sunLon: sunLon,
      );

      expect(res.isDay, isTrue);
      expect(res.yamagandan.rasi, equals(11)); // கும்பம் (Aquarius)
      expect(res.yamagandan.degree, closeTo(25.35, 0.01));
    });

    test('User Screenshot Case: 11/10/2026 05:55:53 AM (Saturday Night / சனிக்கிழமை இரவு)', () {
      // 11/10/2026 | 5:55:53 AM (Before Sunrise) -> சனிக்கிழமை இரவு
      // சூரி பாகை (கன்னி) = 23° 29' (23.4833°)
      // சனி இரவு எ. பாகை = 216.00
      // கூட்டுத்தொகை = 239.4833
      // கன்னி (30) ... மீனம் (210) கழித்தால் மீதம் = மேஷம் 29° 29' (29.4833°)
      final dt = DateTime(2026, 10, 11, 5, 55, 53);
      final sunrise = DateTime(2026, 10, 10, 6, 5, 0); // Saturday sunrise
      final sunset = DateTime(2026, 10, 10, 18, 5, 0);  // Saturday sunset
      final nextSunrise = DateTime(2026, 10, 11, 6, 5, 0); // Sunday sunrise
      const double sunLon = 150.0 + (23.0 + 29.0 / 60.0); // Kanni 23° 29'

      final res = calculateAllJamakkolSubPlanets(
        currentTime: dt,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: nextSunrise,
        prevSunset: sunset.subtract(const Duration(days: 1)),
        sunLon: sunLon,
      );

      expect(res.isDay, isFalse);
      expect(res.yamagandan.rasi, equals(1)); // மேஷம் (Aries)
      expect(res.yamagandan.degree, closeTo(29.4833, 0.01));
    });

    test('All Weekdays Day and Night Yamagandan Offsets Verification', () {
      // Day: ஞா=108, தி=84, செ=60, பு=36, வி=12, வெ=156, சனி=132
      const yamaDay = [108.0, 84.0, 60.0, 36.0, 12.0, 156.0, 132.0];
      // Night: ஞா=192, தி=336, செ=312, பு=288, வி=264, வெ=240, சனி=216
      const yamaNight = [192.0, 336.0, 312.0, 288.0, 264.0, 240.0, 216.0];

      // Sun at 10.0° in Mesham (0° to 30°)
      const double sunDeg = 10.0;
      const double sunLon = 10.0; // Mesham index 0

      for (int w = 0; w < 7; w++) {
        // Day test
        double dayTotal = sunDeg + yamaDay[w];
        int expectedDayRasi = ((dayTotal / 30.0).floor() % 12) + 1;
        double expectedDayDeg = dayTotal % 30.0;

        // Night test
        double nightTotal = sunDeg + yamaNight[w];
        int expectedNightRasi = ((nightTotal / 30.0).floor() % 12) + 1;
        double expectedNightDeg = nightTotal % 30.0;

        // Simulate Sunday(0) to Saturday(6)
        // 2026-10-11 is Sunday
        final dayTime = DateTime(2026, 10, 11 + w, 12, 0, 0);
        final nightTime = DateTime(2026, 10, 11 + w, 22, 0, 0);
        final sr = DateTime(2026, 10, 11 + w, 6, 0, 0);
        final ss = DateTime(2026, 10, 11 + w, 18, 0, 0);

        final resDay = calculateAllJamakkolSubPlanets(
          currentTime: dayTime,
          sunrise: sr,
          sunset: ss,
          nextSunrise: sr.add(const Duration(days: 1)),
          prevSunset: ss.subtract(const Duration(days: 1)),
          sunLon: sunLon,
        );

        expect(resDay.yamagandan.rasi, equals(expectedDayRasi));
        expect(resDay.yamagandan.degree, closeTo(expectedDayDeg, 0.001));

        final resNight = calculateAllJamakkolSubPlanets(
          currentTime: nightTime,
          sunrise: sr,
          sunset: ss,
          nextSunrise: sr.add(const Duration(days: 1)),
          prevSunset: ss.subtract(const Duration(days: 1)),
          sunLon: sunLon,
        );

        expect(resNight.yamagandan.rasi, equals(expectedNightRasi));
        expect(resNight.yamagandan.degree, closeTo(expectedNightDeg, 0.001));
      }
    });
  });
}
