import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  test('Test Jamakkol SubPlanets for 31/12/2026 23:59:59 at Namakkal', () {
    DateTime dt = DateTime(2026, 12, 31, 23, 59, 59);
    DateTime sunrise = DateTime(2026, 12, 31, 6, 36, 0);
    DateTime sunset = DateTime(2026, 12, 31, 18, 5, 0);
    DateTime nextSunrise = DateTime(2027, 1, 1, 6, 37, 0);
    DateTime prevSunset = DateTime(2026, 12, 30, 18, 5, 0);
    double sunLon = 255.57;

    final subPlanets = calculateAllJamakkolSubPlanets(
      currentTime: dt,
      sunrise: sunrise,
      sunset: sunset,
      nextSunrise: nextSunrise,
      prevSunset: prevSunset,
      sunLon: sunLon,
    );

    print("--- 31/12/2026 23:59:59 ---");
    print("IsDay: ${subPlanets.isDay}");
    print("CurrentYama: ${subPlanets.currentYama}");
    print("Rahu: Rasi=${subPlanets.rahu.rasi}, Degree=${subPlanets.rahu.degree}");
    print("Yamagandan: Rasi=${subPlanets.yamagandan.rasi}, Degree=${subPlanets.yamagandan.degree}");
    print("Mrityu: Rasi=${subPlanets.mrityu.rasi}, Degree=${subPlanets.mrityu.degree}");

    expect(subPlanets.rahu.rasi, equals(3)); // Gemini (மிதுனம்)
    expect(subPlanets.yamagandan.rasi, equals(9)); // Sagittarius (தனுசு)
    expect(subPlanets.mrityu.rasi, equals(3)); // Gemini (மிதுனம்)
  });

  test('Test Jamakkol SubPlanets for 28/02/2026 10:57:11 AM at Namakkal', () {
    DateTime dt = DateTime(2026, 2, 28, 10, 57, 11);
    DateTime sunrise = DateTime(2026, 2, 28, 6, 36, 0);
    DateTime sunset = DateTime(2026, 2, 28, 18, 21, 0);
    DateTime nextSunrise = DateTime(2026, 3, 1, 6, 35, 0);
    DateTime prevSunset = DateTime(2026, 2, 27, 18, 21, 0);
    double sunLon = 315.30; // Masi (Aquarius)

    final subPlanets = calculateAllJamakkolSubPlanets(
      currentTime: dt,
      sunrise: sunrise,
      sunset: sunset,
      nextSunrise: nextSunrise,
      prevSunset: prevSunset,
      sunLon: sunLon,
    );

    print("--- 28/02/2026 10:57:11 AM ---");
    print("IsDay: ${subPlanets.isDay}");
    print("CurrentYama: ${subPlanets.currentYama}");
    print("Rahu: Rasi=${subPlanets.rahu.rasi}, Degree=${subPlanets.rahu.degree}");
    print("Yamagandan: Rasi=${subPlanets.yamagandan.rasi}, Degree=${subPlanets.yamagandan.degree}");
    print("Mrityu: Rasi=${subPlanets.mrityu.rasi}, Degree=${subPlanets.mrityu.degree}");

    expect(subPlanets.rahu.rasi, equals(1)); // Aries (மேஷம்)
    expect(subPlanets.mrityu.rasi, equals(2)); // Taurus (ரிஷபம்)
    expect(subPlanets.yamagandan.rasi, equals(3)); // Gemini (மிதுனம்)
  });

  test('Test Jamakkol SubPlanets with real Namakkal sunrise/sunset for 28/02/2026 10:57:11 AM', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await KPService.init();

    DateTime dt = DateTime(2026, 2, 28, 10, 57, 11);
    final results = await KPService.calculateChart(
      'Namakkal',
      dt,
      11.2189,
      78.1674,
      5.5,
      yearLength: 365.25,
      siderealModeIndex: 0,
    );

    final pancha = results['panchangam'];
    String sunriseStr = pancha['sunrise'];
    String sunsetStr = pancha['sunset'];

    print("Namakkal 28/02/2026 - Sunrise: $sunriseStr, Sunset: $sunsetStr");

    DateTime parseTime(String timeStr, DateTime baseDate) {
      final parts = timeStr.split(' ');
      final hms = parts[0].split(':');
      int h = int.parse(hms[0]);
      int m = int.parse(hms[1]);
      int s = hms.length > 2 ? int.parse(hms[2]) : 0;
      if (parts[1] == "PM" && h < 12) h += 12;
      if (parts[1] == "AM" && h == 12) h = 0;
      return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m, s);
    }

    DateTime sunrise = parseTime(sunriseStr, dt);
    DateTime sunset = parseTime(sunsetStr, dt);

    double sunLon = results['planet_details']['sun']['longitude'];

    final subPlanets = calculateAllJamakkolSubPlanets(
      currentTime: dt,
      sunrise: sunrise,
      sunset: sunset,
      nextSunrise: sunrise.add(const Duration(days: 1)),
      prevSunset: sunset.subtract(const Duration(days: 1)),
      sunLon: sunLon,
    );

    print("\n--- PRECISE DEGREES FOR 28/02/2026 10:57:11 AM Namakkal ---");
    print("Sunrise: $sunrise, Sunset: $sunset");
    print("Current Jama (Day): ${subPlanets.currentYama}");
    print("Rahu Kaalam (ரா.கா): Rasi ${subPlanets.rahu.rasi} (Rishabam/Taurus) -> ${subPlanets.rahu.degree.toStringAsFixed(2)}° (${subPlanets.rahu.degree.floor()}° ${((subPlanets.rahu.degree - subPlanets.rahu.degree.floor()) * 60).floor()}')");
    print("Yamagandan (யம): Rasi ${subPlanets.yamagandan.rasi} (Kadagam/Cancer) -> ${subPlanets.yamagandan.degree.toStringAsFixed(2)}° (${subPlanets.yamagandan.degree.floor()}° ${((subPlanets.yamagandan.degree - subPlanets.yamagandan.degree.floor()) * 60).floor()}')");
    print("Mrityu (மிரு): Rasi ${subPlanets.mrityu.rasi} (Mithunam/Gemini) -> ${subPlanets.mrityu.degree.toStringAsFixed(2)}° (${subPlanets.mrityu.degree.floor()}° ${((subPlanets.mrityu.degree - subPlanets.mrityu.degree.floor()) * 60).floor()}')");
  });
}
