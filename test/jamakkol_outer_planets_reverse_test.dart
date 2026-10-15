import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  group('Jamakkol Outer Planets Reverse Movement Verification', () {
    test('Sunday at 6:00 AM - Initial Placements (Reverse 45 deg intervals)', () {
      final dt = DateTime(2026, 10, 11, 6, 0, 0); // Sunday
      final sunrise = DateTime(2026, 10, 11, 6, 0, 0);
      final sunset = DateTime(2026, 10, 11, 18, 0, 0);

      final res = JamakkolService.calculate(
        dt,
        sunrise,
        13.0827,
        80.2707,
        5.5,
        6,
        sunset: sunset,
      );

      final pDegs = res['planet_degrees'] as Map<String, double>;

      // Sun (Day Lord) -> 0° (Mesham 0°)
      expect(pDegs['Sun'], closeTo(0.0, 0.01));
      // Mars -> 315° (Kumbham 15°)
      expect(pDegs['Mars'], closeTo(315.0, 0.01));
      // Jupiter -> 270° (Makaram 0°)
      expect(pDegs['Jupiter'], closeTo(270.0, 0.01));
      // Mercury -> 225° (Virgo/Scorpio -> Scorpio 15°)
      expect(pDegs['Mercury'], closeTo(225.0, 0.01));
      // Venus -> 180° (Libra 0°)
      expect(pDegs['Venus'], closeTo(180.0, 0.01));
      // Saturn -> 135° (Leo 15°)
      expect(pDegs['Saturn'], closeTo(135.0, 0.01));
      // Moon -> 90° (Cancer 0°)
      expect(pDegs['Moon'], closeTo(90.0, 0.01));
      // Rahu -> 45° (Taurus 15°)
      expect(pDegs['Rahu'], closeTo(45.0, 0.01));
    });

    test('Sunday at 6:30 AM - Moved 15 deg in Reverse (anti-clockwise)', () {
      final dt = DateTime(2026, 10, 11, 6, 30, 0); // 30 mins elapsed => 15° moved reverse
      final sunrise = DateTime(2026, 10, 11, 6, 0, 0);
      final sunset = DateTime(2026, 10, 11, 18, 0, 0);

      final res = JamakkolService.calculate(
        dt,
        sunrise,
        13.0827,
        80.2707,
        5.5,
        6,
        sunset: sunset,
      );

      final pDegs = res['planet_degrees'] as Map<String, double>;

      // Sun should be at (360 - 15) = 345° (Pisces 15°)
      expect(pDegs['Sun'], closeTo(345.0, 0.01));
      // Mars should be at (315 - 15) = 300° (Capricorn 30° / Aquarius 0°)
      expect(pDegs['Mars'], closeTo(300.0, 0.01));
      // Jupiter should be at (270 - 15) = 255° (Sagittarius 15°)
      expect(pDegs['Jupiter'], closeTo(255.0, 0.01));
    });

    test('Sunday at 7:30 AM (Jamam 2 begins) - Moved 45 deg in Reverse', () {
      final dt = DateTime(2026, 10, 11, 7, 30, 0); // 90 mins elapsed => 45° moved reverse
      final sunrise = DateTime(2026, 10, 11, 6, 0, 0);
      final sunset = DateTime(2026, 10, 11, 18, 0, 0);

      final res = JamakkolService.calculate(
        dt,
        sunrise,
        13.0827,
        80.2707,
        5.5,
        6,
        sunset: sunset,
      );

      final pDegs = res['planet_degrees'] as Map<String, double>;

      // Sun should be at (360 - 45) = 315° (Aquarius 15°)
      expect(pDegs['Sun'], closeTo(315.0, 0.01));
      // Mars should be at (315 - 45) = 270° (Capricorn 0°)
      expect(pDegs['Mars'], closeTo(270.0, 0.01));
      // Current Jamam Planet at 7:30 AM is Mars (Yama 2)
      expect(res['current_jamam_planet'], equals('Mars'));
    });
  });
}
