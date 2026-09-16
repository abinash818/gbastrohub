import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  test('Test 1: Mon, 15-06-2026 12:00:00 PM at Namakkal (Monday Day, Yama 4)', () {
    DateTime dt = DateTime(2026, 6, 15, 12, 0, 0);
    DateTime sunrise = DateTime(2026, 6, 15, 5, 55, 0);
    DateTime sunset = DateTime(2026, 6, 15, 18, 42, 0);
    DateTime nextSunrise = DateTime(2026, 6, 16, 5, 55, 0);
    DateTime prevSunset = DateTime(2026, 6, 14, 18, 42, 0);
    double sunLon = 60.03; // Mithunam 00.03°

    final subPlanets = calculateAllJamakkolSubPlanets(
      currentTime: dt,
      sunrise: sunrise,
      sunset: sunset,
      nextSunrise: nextSunrise,
      prevSunset: prevSunset,
      sunLon: sunLon,
    );

    print("--- Mon, 15-06-2026 12:00:00 PM (Monday Day, Yama 4) ---");
    print("IsDay: ${subPlanets.isDay}, Yama: ${subPlanets.currentYama}");
    print("Rahu (ரா.கா): Rasi=${subPlanets.rahu.rasi} (Mithunam)");
    print("Mrityu (மிரு): Rasi=${subPlanets.mrityu.rasi} (Mithunam)");
    print("Yamagandan (யம): Rasi=${subPlanets.yamagandan.rasi} (Simham)");

    expect(subPlanets.currentYama, equals(4));
    expect(subPlanets.rahu.rasi, equals(3)); // Mithunam (மிதுனம் - (11 + 4 - 1)%12 = 2 -> index 2 + 1 = 3)
    expect(subPlanets.mrityu.rasi, equals(3)); // Mithunam (மிதுனம் - (11 + 4 - 1)%12 = 2 -> index 2 + 1 = 3)
    expect(subPlanets.yamagandan.rasi, equals(5)); // Simham (சிம்மம் - (1 + 4 - 1)%12 = 4 -> index 4 + 1 = 5)
  });

  test('Test 2: Tue, 15-09-2026 11:31:10 PM at Namakkal (Tuesday Night, Yama 4)', () {
    DateTime dt = DateTime(2026, 9, 15, 23, 31, 10);
    DateTime sunrise = DateTime(2026, 9, 15, 6, 8, 0);
    DateTime sunset = DateTime(2026, 9, 15, 18, 20, 0);
    DateTime nextSunrise = DateTime(2026, 9, 16, 6, 8, 0);
    DateTime prevSunset = DateTime(2026, 9, 14, 18, 20, 0);
    double sunLon = 147.48; // Simham 27.48°

    final subPlanets = calculateAllJamakkolSubPlanets(
      currentTime: dt,
      sunrise: sunrise,
      sunset: sunset,
      nextSunrise: nextSunrise,
      prevSunset: prevSunset,
      sunLon: sunLon,
    );

    print("--- Tue, 15-09-2026 11:31:10 PM (Tuesday Night, Yama 4) ---");
    print("IsDay: ${subPlanets.isDay}, Yama: ${subPlanets.currentYama}");
    print("Rahu (ரா.கா): Rasi=${subPlanets.rahu.rasi} (Mesham)");
    print("Mrityu (மிரு): Rasi=${subPlanets.mrityu.rasi} (Rishabham)");
    print("Yamagandan (யம): Rasi=${subPlanets.yamagandan.rasi} (Mithunam)");

    expect(subPlanets.currentYama, equals(4));
    expect(subPlanets.rahu.rasi, equals(1)); // (9 + 4 - 1)%12 = 0 -> Mesham (1)
    expect(subPlanets.mrityu.rasi, equals(2)); // (10 + 4 - 1)%12 = 1 -> Rishabham (2)
    expect(subPlanets.yamagandan.rasi, equals(3)); // (11 + 4 - 1)%12 = 2 -> Mithunam (3)
  });
}
