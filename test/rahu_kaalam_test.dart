import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';

void main() {
  const List<String> rasiNames = [
    "Aries (மேஷம்)", "Taurus (ரிஷபம்)", "Gemini (மிதுனம்)", "Cancer (கடகம்)",
    "Leo (சிம்மம்)", "Virgo (கன்னி)", "Libra (துலாம்)", "Scorpio (விருச்சிகம்)",
    "Sagittarius (தனுசு)", "Capricorn (மகரம்)", "Aquarius (கும்பம்)", "Pisces (மீனம்)"
  ];

  group('Jamakkol Rahu Kaalam Calculation Tests', () {
    test('Example 1: 11/10/26 Sunday Day (ஞாயிறு பகல்)', () {
      // 11/10/26 | NKL | 9.43.13 AM | ஞாயிறு
      // சூரி. பாகை (கன்னி) = 23.38 (ஞா - 180)
      // ஞா. கு. பாகை = 180.00
      // கூட்டுத்தொகை = 203.38
      // அடுத்த ராசியில் 23.38 வரும் -> மீனம் 23.38
      final dt = DateTime(2026, 10, 11, 9, 43, 13);
      final sunrise = DateTime(2026, 10, 11, 6, 5, 0);
      final sunset = DateTime(2026, 10, 11, 18, 0, 0);
      // Kanni is index 5 (150 to 180). Absolute lon = 150 + 23.38 = 173.38
      const double sunLon = 150.0 + 23.38;

      final res = calculateAllJamakkolSubPlanets(
        currentTime: dt,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: sunrise.add(const Duration(days: 1)),
        prevSunset: sunset.subtract(const Duration(days: 1)),
        sunLon: sunLon,
      );

      expect(res.isDay, isTrue);
      expect(res.rahu.rasi, equals(12)); // Pisces (மீனம் - 12)
      expect(closeTo(res.rahu.degree, 23.38, 0.001), isTrue);
    });

    test('Example 2: 12/10/26 Monday Day (திங்கள் பகல்)', () {
      // 12/10/26 (திங்கள் - 36°)
      // சூரி - பாகை = 24.37 (கன்னி)
      // கு. பாகை = 36.00
      // கூட்டுத்தொகை = 60.37
      // சூரி கன்னி — 30, துலாம் — 60, விருச்சிகம் = 00.37 இல் வரும்.
      final dt = DateTime(2026, 10, 12, 10, 0, 0);
      final sunrise = DateTime(2026, 10, 12, 6, 5, 0);
      final sunset = DateTime(2026, 10, 12, 18, 0, 0);
      // Kanni is index 5. Absolute lon = 150 + 24.37 = 174.37
      const double sunLon = 150.0 + 24.37;

      final res = calculateAllJamakkolSubPlanets(
        currentTime: dt,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: sunrise.add(const Duration(days: 1)),
        prevSunset: sunset.subtract(const Duration(days: 1)),
        sunLon: sunLon,
      );

      expect(res.isDay, isTrue);
      expect(res.rahu.rasi, equals(8)); // Scorpio (விருச்சிகம் - 8)
      expect(closeTo(res.rahu.degree, 0.37, 0.001), isTrue);
    });

    test('Example 3: 29/10/26 Thursday Night (வியாழன் இரவு)', () {
      // 29/10/26 | 9.43.00 PM | NKL | (வியாழக்கிழமை) இரவு
      // சூரி பாகை = 12.07 (துலாம்)
      // வி. இரவு பாகை = 216.00
      // கூட்டுத்தொகை = 228.07 - 210 (மேஷம்)
      // மீதி = ரிஷபம் 18.07 பாகையில் அமையும்.
      final dt = DateTime(2026, 10, 29, 21, 43, 0);
      final sunrise = DateTime(2026, 10, 29, 6, 5, 0);
      final sunset = DateTime(2026, 10, 29, 17, 55, 0);
      // Thulam is index 6. Absolute lon = 180 + 12.07 = 192.07
      const double sunLon = 180.0 + 12.07;

      final res = calculateAllJamakkolSubPlanets(
        currentTime: dt,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: sunrise.add(const Duration(days: 1)),
        prevSunset: sunset.subtract(const Duration(days: 1)),
        sunLon: sunLon,
      );

      expect(res.isDay, isFalse);
      expect(res.rahu.rasi, equals(2)); // Taurus (ரிஷபம் - 2)
      expect(closeTo(res.rahu.degree, 18.07, 0.001), isTrue);
    });

    test('Example 4: 13/10/26 Tuesday Day (செவ்வாய் பகல்)', () {
      // 13/10/26 (செவ்வாய் - 156°)
      // சூரி பாகை = 25.36 (கன்னி)
      // கு. பாகை = 156.00
      // கூட்டுத்தொகை = 181.36
      // கன்னி (index 5) + 6 ராசிகள் = மீனம் (12) 01.36°
      final dt = DateTime(2026, 10, 13, 10, 0, 0);
      final sunrise = DateTime(2026, 10, 13, 6, 5, 0);
      final sunset = DateTime(2026, 10, 13, 18, 0, 0);
      const double sunLon = 150.0 + 25.36;

      final res = calculateAllJamakkolSubPlanets(
        currentTime: dt,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: sunrise.add(const Duration(days: 1)),
        prevSunset: sunset.subtract(const Duration(days: 1)),
        sunLon: sunLon,
      );

      expect(res.isDay, isTrue);
      expect(res.rahu.rasi, equals(12)); // Pisces (மீனம் - 12)
      expect(closeTo(res.rahu.degree, 1.36, 0.001), isTrue);
    });

    test('Example 5: 14/10/26 Wednesday Day (புதன் பகல்)', () {
      // 14/10/26 (புதன் - 108°)
      // சூரி பாகை = 26.35 (கன்னி)
      // கு. பாகை = 108.00
      // கூட்டுத்தொகை = 134.35
      // கன்னி (index 5) + 4 ராசிகள் = மகரம் (10) 14.35°
      final dt = DateTime(2026, 10, 14, 10, 0, 0);
      final sunrise = DateTime(2026, 10, 14, 6, 5, 0);
      final sunset = DateTime(2026, 10, 14, 18, 0, 0);
      const double sunLon = 150.0 + 26.35;

      final res = calculateAllJamakkolSubPlanets(
        currentTime: dt,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: sunrise.add(const Duration(days: 1)),
        prevSunset: sunset.subtract(const Duration(days: 1)),
        sunLon: sunLon,
      );

      expect(res.isDay, isTrue);
      expect(res.rahu.rasi, equals(10)); // Capricorn (மகரம் - 10)
      expect(closeTo(res.rahu.degree, 14.35, 0.001), isTrue);
    });

    test('All Weekdays Day and Night Degree Offsets', () {
      // Test all 7 weekdays
      final dayOffsets = [180.0, 36.0, 156.0, 108.0, 132.0, 84.0, 60.0];
      final nightOffsets = [264.0, 288.0, 240.0, 0.0, 216.0, 336.0, 312.0];

      // Base date: 2026-10-11 is Sunday (weekday % 7 = 0)
      for (int i = 0; i < 7; i++) {
        final dayDate = DateTime(2026, 10, 11 + i, 10, 0, 0);
        final nightDate = DateTime(2026, 10, 11 + i, 22, 0, 0);
        final sunrise = DateTime(2026, 10, 11 + i, 6, 0, 0);
        final sunset = DateTime(2026, 10, 11 + i, 18, 0, 0);
        const double sunLon = 150.0 + 10.0; // Virgo 10°

        // Day
        final dayRes = calculateAllJamakkolSubPlanets(
          currentTime: dayDate,
          sunrise: sunrise,
          sunset: sunset,
          nextSunrise: sunrise.add(const Duration(days: 1)),
          prevSunset: sunset.subtract(const Duration(days: 1)),
          sunLon: sunLon,
        );
        double expectedDaySum = 10.0 + dayOffsets[i];
        int expectedDayRasi = (5 + (expectedDaySum / 30.0).floor()) % 12 + 1;
        double expectedDayDeg = expectedDaySum % 30.0;

        expect(dayRes.isDay, isTrue);
        expect(dayRes.rahu.rasi, equals(expectedDayRasi));
        expect(closeTo(dayRes.rahu.degree, expectedDayDeg, 0.001), isTrue);

        // Night
        final nightRes = calculateAllJamakkolSubPlanets(
          currentTime: nightDate,
          sunrise: sunrise,
          sunset: sunset,
          nextSunrise: sunrise.add(const Duration(days: 1)),
          prevSunset: sunset.subtract(const Duration(days: 1)),
          sunLon: sunLon,
        );
        double expectedNightSum = 10.0 + nightOffsets[i];
        int expectedNightRasi = (5 + (expectedNightSum / 30.0).floor()) % 12 + 1;
        double expectedNightDeg = expectedNightSum % 30.0;

        expect(nightRes.isDay, isFalse);
        expect(nightRes.rahu.rasi, equals(expectedNightRasi));
        expect(closeTo(nightRes.rahu.degree, expectedNightDeg, 0.001), isTrue);
      }
    });
  });

  group('Jamakkol Mrityu Calculation Tests', () {
    test('Mrityu Example 1: 09/10/26 Friday Day (வெள்ளி பகல்)', () {
      // 9-10-26 | NKL | 11.22 AM (வெள்ளிக்கிழமை)
      // சூரி பாகை (கன்னி) = 21.43
      // வெ. மிரு. பாகை (+) = 108.00
      // கூட்டுத்தொகை = 129.43
      // சூரி இருக்கும் கன்னி — 30, துலாம் — 60, விருச்சிகம் — 90, தனுசு — 120
      // மகரம் மீதி = 9.43 மிருத்யு பாகை
      final dt = DateTime(2026, 10, 9, 11, 22, 0);
      final sunrise = DateTime(2026, 10, 9, 6, 5, 0);
      final sunset = DateTime(2026, 10, 9, 18, 0, 0);
      // Kanni is index 5. Absolute lon = 150 + 21.43 = 171.43
      const double sunLon = 150.0 + 21.43;

      final res = calculateAllJamakkolSubPlanets(
        currentTime: dt,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: sunrise.add(const Duration(days: 1)),
        prevSunset: sunset.subtract(const Duration(days: 1)),
        sunLon: sunLon,
      );

      expect(res.isDay, isTrue);
      expect(res.mrityu.rasi, equals(10)); // Capricorn (மகரம் - 10)
      expect(closeTo(res.mrityu.degree, 9.43, 0.001), isTrue);
    });

    test('Mrityu Example 2: 31/10/26 Saturday Night (சனி இரவு)', () {
      // 31-10-26 | NKL | 11.53 PM | சனிக்கிழமை
      // சூரி பாகை (துலாம்) = 14.12
      // கிழமையின் பாகை (இரவு) = 336.00
      // கூட்டுத்தொகை = 350.12
      // சூரி இருக்கும் ராசியில் இருந்து: துலாம் — 30, விருச்சிகம் — 60 ... சிம்மம் வரை 330
      // மீதி = கன்னி 20.12 பாகை (மிருத்யு இரவு நேரத்திற்கு)
      final dt = DateTime(2026, 10, 31, 23, 53, 0);
      final sunrise = DateTime(2026, 10, 31, 6, 5, 0);
      final sunset = DateTime(2026, 10, 31, 17, 50, 0);
      // Thulam is index 6. Absolute lon = 180 + 14.12 = 194.12
      const double sunLon = 180.0 + 14.12;

      final res = calculateAllJamakkolSubPlanets(
        currentTime: dt,
        sunrise: sunrise,
        sunset: sunset,
        nextSunrise: sunrise.add(const Duration(days: 1)),
        prevSunset: sunset.subtract(const Duration(days: 1)),
        sunLon: sunLon,
      );

      expect(res.isDay, isFalse);
      expect(res.mrityu.rasi, equals(6)); // Virgo (கன்னி - 6)
      expect(closeTo(res.mrityu.degree, 20.12, 0.001), isTrue);
    });

    test('All Weekdays Day and Night Mrityu Offsets', () {
      // Mrityu:
      // Day: ஞா=60, தி=36, செ=12, பு=156, வி=132, வெ=108, சனி=84
      // Night: ஞா=312, தி=288, செ=264, பு=240, வி=216, வெ=192, சனி=336
      final dayOffsets = [60.0, 36.0, 12.0, 156.0, 132.0, 108.0, 84.0];
      final nightOffsets = [312.0, 288.0, 264.0, 240.0, 216.0, 192.0, 336.0];

      // Base date: 2026-10-11 is Sunday (weekday % 7 = 0)
      for (int i = 0; i < 7; i++) {
        final dayDate = DateTime(2026, 10, 11 + i, 10, 0, 0);
        final nightDate = DateTime(2026, 10, 11 + i, 22, 0, 0);
        final sunrise = DateTime(2026, 10, 11 + i, 6, 0, 0);
        final sunset = DateTime(2026, 10, 11 + i, 18, 0, 0);
        const double sunLon = 150.0 + 10.0; // Virgo 10°

        // Day
        final dayRes = calculateAllJamakkolSubPlanets(
          currentTime: dayDate,
          sunrise: sunrise,
          sunset: sunset,
          nextSunrise: sunrise.add(const Duration(days: 1)),
          prevSunset: sunset.subtract(const Duration(days: 1)),
          sunLon: sunLon,
        );
        double expectedDaySum = 10.0 + dayOffsets[i];
        int expectedDayRasi = (5 + (expectedDaySum / 30.0).floor()) % 12 + 1;
        double expectedDayDeg = expectedDaySum % 30.0;

        expect(dayRes.isDay, isTrue);
        expect(dayRes.mrityu.rasi, equals(expectedDayRasi));
        expect(closeTo(dayRes.mrityu.degree, expectedDayDeg, 0.001), isTrue);

        // Night
        final nightRes = calculateAllJamakkolSubPlanets(
          currentTime: nightDate,
          sunrise: sunrise,
          sunset: sunset,
          nextSunrise: sunrise.add(const Duration(days: 1)),
          prevSunset: sunset.subtract(const Duration(days: 1)),
          sunLon: sunLon,
        );
        double expectedNightSum = 10.0 + nightOffsets[i];
        int expectedNightRasi = (5 + (expectedNightSum / 30.0).floor()) % 12 + 1;
        double expectedNightDeg = expectedNightSum % 30.0;

        expect(nightRes.isDay, isFalse);
        expect(nightRes.mrityu.rasi, equals(expectedNightRasi));
        expect(closeTo(nightRes.mrityu.degree, expectedNightDeg, 0.001), isTrue);
      }
    });
  });
}

bool closeTo(double a, double b, double delta) => (a - b).abs() <= delta;
