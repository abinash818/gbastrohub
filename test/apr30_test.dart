import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Calculate SubPlanets for 30-04-2026 23:59:59', () async {
    await KPService.init();

    final dt = DateTime(2026, 4, 30, 23, 59, 59);
    final results = await KPService.calculateChart(
      'Apr30Test',
      dt,
      11.2189,
      78.1674,
      5.5,
      yearLength: 365.25,
      siderealModeIndex: 0,
    );

    final sun = results['planet_details']['sun'];
    double sunLon = (sun['longitude'] as num).toDouble();

    // 30-04-2026 Sunrise/Sunset for Namakkal
    DateTime sunrise = DateTime(2026, 4, 30, 6, 2, 0);
    DateTime sunset = DateTime(2026, 4, 30, 18, 30, 0);
    DateTime nextSunrise = DateTime(2026, 5, 1, 6, 2, 0);
    DateTime prevSunset = DateTime(2026, 4, 29, 18, 30, 0);

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
    print('30-04-2026 23:59:59 (Thursday Night) - NAMAKKAL');
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
      return '$label : $rasiName (${sp.rasi}) @ ${d.toString().padLeft(2, '0')}°${m.toString().padLeft(2, '0')}\' (பாகை: ${sp.degree.toStringAsFixed(2)}°, 360°: ${absDeg.toStringAsFixed(2)}°)';
    }

    print(printSubPlanet('ராகு காலம் (ரா.கா)', subPlanets.rahu));
    print(printSubPlanet('எமகண்டன்   (யம)  ', subPlanets.yamagandan));
    print(printSubPlanet('மிருத்யு     (மிரு) ', subPlanets.mrityu));
    print(printSubPlanet('மரணம்       (மார) ', subPlanets.marana));
  });
}
