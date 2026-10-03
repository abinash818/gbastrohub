import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';

void main() {
  test('Test Wed 16-09-2026 09:48:51 AM', () {
    final res = calculateAllJamakkolSubPlanets(
      currentTime: DateTime(2026, 9, 16, 9, 48, 51),
      sunrise: DateTime(2026, 9, 16, 6, 8, 0),
      sunset: DateTime(2026, 9, 16, 18, 19, 0),
      nextSunrise: DateTime(2026, 9, 17, 6, 8, 0),
      prevSunset: DateTime(2026, 9, 15, 18, 20, 0),
      sunLon: 149.12, // Simmam 29.12°
    );

    const List<String> tamilRasis = [
      "மேஷம்", "ரிஷபம்", "மிதுனம்", "கடகம்",
      "சிம்மம்", "கன்னி", "துலாம்", "விருச்சிகம்",
      "தனுசு", "மகரம்", "கும்பம்", "மீனம்"
    ];

    print('IsDay: ${res.isDay}, Yama: ${res.currentYama}');
    print('Rahu (ரா.கா): Rasi ${res.rahu.rasi} (${tamilRasis[res.rahu.rasi - 1]}) ${res.rahu.degree}');
    print('Yama (யம): Rasi ${res.yamagandan.rasi} (${tamilRasis[res.yamagandan.rasi - 1]}) ${res.yamagandan.degree}');
    print('Mrityu (மிரு): Rasi ${res.mrityu.rasi} (${tamilRasis[res.mrityu.rasi - 1]}) ${res.mrityu.degree}');
  });
}
