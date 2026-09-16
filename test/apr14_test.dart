import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Calculate SubPlanets for 14-04-2026 11:59:59 PM', () async {
    await KPService.init();

    final dt = DateTime(2026, 4, 14, 23, 59, 59);
    final results = await KPService.calculateChart(
      'Apr14Test',
      dt,
      11.2189,
      78.1674,
      5.5,
      yearLength: 365.25,
      siderealModeIndex: 0,
    );

    final sun = results['planet_details']['sun'];
    double sunLon = (sun['longitude'] as num).toDouble();

    final pancha = results['panchangam'];
    String sunriseStr = pancha['sunrise'] ?? "06:10 AM";
    String sunsetStr = pancha['sunset'] ?? "06:25 PM";

    // Parse Sunrise and Sunset
    DateTime sunrise = DateTime(2026, 4, 14, 6, 10, 0);
    DateTime sunset = DateTime(2026, 4, 14, 18, 25, 0);
    DateTime nextSunrise = DateTime(2026, 4, 15, 6, 10, 0);
    DateTime prevSunset = DateTime(2026, 4, 13, 18, 25, 0);

    final subPlanets = calculateAllJamakkolSubPlanets(
      currentTime: dt,
      sunrise: sunrise,
      sunset: sunset,
      nextSunrise: nextSunrise,
      prevSunset: prevSunset,
      sunLon: sunLon,
    );

    const List<String> tamilRasis = [
      "மேஷம்", "ரிஷபம்", "மிதுனம்", "கடகம்",
      "சிம்மம்", "கன்னி", "துலாம்", "விருச்சிகம்",
      "தனுசு", "மகரம்", "கும்பம்", "மீனம்"
    ];

    print('\n======================================================');
    print('14-04-2026 11:59:59 PM - SUBPLANET CALCULATION');
    print('======================================================');
    print('சூரியன் (Sun): ${sun['rasi']} ${(sunLon % 30).toStringAsFixed(2)}° (360°: ${sunLon.toStringAsFixed(2)}°)');
    print('பகல்/இரவு: ${subPlanets.isDay ? "பகல் (Day)" : "இரவு (Night)"}');
    print('நடப்பு ஜாமம்: ${subPlanets.currentYama}-ஆம் ஜாமம்');
    print('------------------------------------------------------');
    
    String printSubPlanet(String label, SubPlanetResult sp) {
      String rasiName = tamilRasis[sp.rasi - 1];
      double absDeg = ((sp.rasi - 1) * 30.0) + sp.degree;
      int d = sp.degree.floor();
      int m = ((sp.degree - d) * 60).round();
      return '$label : $rasiName ${d.toString().padLeft(2, '0')}°${m.toString().padLeft(2, '0')}\' (பாகை: ${sp.degree.toStringAsFixed(2)}°, 360°: ${absDeg.toStringAsFixed(2)}°)';
    }

    expect(subPlanets.currentYama, equals(4));
    expect(subPlanets.rahu.rasi, equals(11)); // Kumbam (கும்பம்)
    expect(subPlanets.mrityu.rasi, equals(11)); // Kumbam (கும்பம்)
    expect(subPlanets.yamagandan.rasi, equals(11)); // Kumbam (கும்பம்)
    expect(subPlanets.rahu.degree, closeTo(0.59, 0.05));
    expect(subPlanets.mrityu.degree, closeTo(24.59, 0.05));
    expect(subPlanets.yamagandan.degree, closeTo(12.59, 0.05));
  });
}
