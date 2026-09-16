import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  const List<String> tamilRasis = [
    "மேஷம்", "ரிஷபம்", "மிதுனம்", "கடகம்",
    "சிம்மம்", "கன்னி", "துலாம்", "விருச்சிகம்",
    "தனுசு", "மகரம்", "கும்பம்", "மீனம்"
  ];

  String format360(int rasiNumber, double degInSign) {
    int rasiIdx = rasiNumber - 1;
    double absDeg = (rasiIdx * 30.0) + degInSign;
    int d = degInSign.floor();
    int m = ((degInSign - d) * 60).round();
    return "${tamilRasis[rasiIdx]} ${d.toString().padLeft(2, '0')}°${m.toString().padLeft(2, '0')}' (360°: ${absDeg.toStringAsFixed(2)}°)";
  }

  group('Jamakkol 5 Horoscopes 360 Degree Validation', () {
    test('Horoscope 1: Wed 16-09-2026 06:12:00 AM (Wednesday Day, Yama 1)', () {
      final res = calculateAllJamakkolSubPlanets(
        currentTime: DateTime(2026, 9, 16, 6, 12, 0),
        sunrise: DateTime(2026, 9, 16, 6, 8, 0),
        sunset: DateTime(2026, 9, 16, 18, 19, 0),
        nextSunrise: DateTime(2026, 9, 17, 6, 8, 0),
        prevSunset: DateTime(2026, 9, 15, 18, 20, 0),
        sunLon: 148.95, // Simmam 28°57'
      );

      print('\n======================================================');
      print('HOROSCOPE 1: புதன் பகல் 1-ஆம் ஜாமம் (16-09-2026 06:12 AM)');
      print('சூரியன்: சிம்மம் 28°57\' (360°: 148.95°)');
      print('------------------------------------------------------');
      print('ராகு காலம் (ரா.கா) : ${format360(res.rahu.rasi, res.rahu.degree)}');
      print('எமகண்டன்   (யம)   : ${format360(res.yamagandan.rasi, res.yamagandan.degree)}');
      print('மிருத்யு     (மிரு) : ${format360(res.mrityu.rasi, res.mrityu.degree)}');

      expect(res.isDay, isTrue);
      expect(res.currentYama, equals(1));
      expect(res.rahu.rasi, equals(5)); // சிம்மம் (Leo - index 4)
      expect(res.yamagandan.rasi, equals(1)); // மேஷம் (Aries - index 0)
      expect(res.mrityu.rasi, equals(2)); // ரிஷபம் (Taurus - index 1)
    });

    test('Horoscope 2: Mon 15-06-2026 12:00:00 PM (Monday Day, Yama 4)', () {
      final res = calculateAllJamakkolSubPlanets(
        currentTime: DateTime(2026, 6, 15, 12, 0, 0),
        sunrise: DateTime(2026, 6, 15, 5, 55, 0),
        sunset: DateTime(2026, 6, 15, 18, 42, 0),
        nextSunrise: DateTime(2026, 6, 16, 5, 55, 0),
        prevSunset: DateTime(2026, 6, 14, 18, 42, 0),
        sunLon: 60.05, // Mithunam 00°03'
      );

      print('\n======================================================');
      print('HOROSCOPE 2: திங்கள் பகல் 4-ஆம் ஜாமம் (15-06-2026 12:00 PM)');
      print('சூரியன்: மிதுனம் 00°03\' (360°: 60.05°)');
      print('------------------------------------------------------');
      print('ராகு காலம் (ரா.கா) : ${format360(res.rahu.rasi, res.rahu.degree)}');
      print('எமகண்டன்   (யம)   : ${format360(res.yamagandan.rasi, res.yamagandan.degree)}');
      print('மிருத்யு     (மிரு) : ${format360(res.mrityu.rasi, res.mrityu.degree)}');

      expect(res.isDay, isTrue);
      expect(res.currentYama, equals(4));
      expect(res.rahu.rasi, equals(3)); // மிதுனம் (Gemini - index 2)
      expect(res.yamagandan.rasi, equals(5)); // சிம்மம் (Leo - index 4)
      expect(res.mrityu.rasi, equals(3)); // மிதுனம் (Gemini - index 2)
    });

    test('Horoscope 3: Tue 15-09-2026 11:31:10 PM (Tuesday Night, Yama 4)', () {
      final res = calculateAllJamakkolSubPlanets(
        currentTime: DateTime(2026, 9, 15, 23, 31, 10),
        sunrise: DateTime(2026, 9, 15, 6, 8, 0),
        sunset: DateTime(2026, 9, 15, 18, 20, 0),
        nextSunrise: DateTime(2026, 9, 16, 6, 8, 0),
        prevSunset: DateTime(2026, 9, 14, 18, 20, 0),
        sunLon: 147.80, // Simmam 27°48'
      );

      print('\n======================================================');
      print('HOROSCOPE 3: செவ்வாய் இரவு 4-ஆம் ஜாமம் (15-09-2026 11:31 PM)');
      print('சூரியன்: சிம்மம் 27°48\' (360°: 147.80°)');
      print('------------------------------------------------------');
      print('ராகு காலம் (ரா.கா) : ${format360(res.rahu.rasi, res.rahu.degree)}');
      print('எமகண்டன்   (யம)   : ${format360(res.yamagandan.rasi, res.yamagandan.degree)}');
      print('மிருத்யு     (மிரு) : ${format360(res.mrityu.rasi, res.mrityu.degree)}');

      expect(res.isDay, isFalse);
      expect(res.currentYama, equals(4));
      expect(res.rahu.rasi, equals(1)); // மேஷம் (Aries - index 0)
      expect(res.yamagandan.rasi, equals(3)); // மிதுனம் (Gemini - index 2)
      expect(res.mrityu.rasi, equals(2)); // ரிஷபம் (Taurus - index 1)
    });

    test('Horoscope 4: Thu 10-09-2026 07:37:25 PM (Thursday Night, Yama 1)', () {
      final res = calculateAllJamakkolSubPlanets(
        currentTime: DateTime(2026, 9, 10, 19, 37, 25),
        sunrise: DateTime(2026, 9, 10, 6, 8, 0),
        sunset: DateTime(2026, 9, 10, 18, 23, 0),
        nextSunrise: DateTime(2026, 9, 11, 6, 8, 0),
        prevSunset: DateTime(2026, 9, 9, 18, 24, 0),
        sunLon: 143.75, // Simmam 23°45'
      );

      print('\n======================================================');
      print('HOROSCOPE 4: வியாழன் இரவு 1-ஆம் ஜாமம் (10-09-2026 07:37 PM)');
      print('சூரியன்: சிம்மம் 23°45\' (360°: 143.75°)');
      print('------------------------------------------------------');
      print('ராகு காலம் (ரா.கா) : ${format360(res.rahu.rasi, res.rahu.degree)}');
      print('எமகண்டன்   (யம)   : ${format360(res.yamagandan.rasi, res.yamagandan.degree)}');
      print('மிருத்யு     (மிரு) : ${format360(res.mrityu.rasi, res.mrityu.degree)}');

      expect(res.isDay, isFalse);
      expect(res.currentYama, equals(1));
      expect(res.rahu.rasi, equals(1)); // மேஷம் (Aries - index 0)
      expect(res.yamagandan.rasi, equals(3)); // மிதுனம் (Gemini - index 2)
      expect(res.mrityu.rasi, equals(1)); // மேஷம் (Aries - index 0)
    });

    test('Horoscope 5: Thu 23-08-1979 10:08:30 PM (Thursday Night, Yama 3)', () {
      final res = calculateAllJamakkolSubPlanets(
        currentTime: DateTime(1979, 8, 23, 22, 8, 30),
        sunrise: DateTime(1979, 8, 23, 6, 8, 0),
        sunset: DateTime(1979, 8, 23, 18, 34, 0),
        nextSunrise: DateTime(1979, 8, 24, 6, 8, 0),
        prevSunset: DateTime(1979, 8, 22, 18, 34, 0),
        sunLon: 126.47, // Simmam 06°28'
      );

      print('\n======================================================');
      print('HOROSCOPE 5: வியாழன் இரவு 3-ஆம் ஜாமம் (23-08-1979 10:08 PM)');
      print('சூரியன்: சிம்மம் 06°28\' (360°: 126.47°)');
      print('------------------------------------------------------');
      print('ராகு காலம் (ரா.கா) : ${format360(res.rahu.rasi, res.rahu.degree)}');
      print('எமகண்டன்   (யம)   : ${format360(res.yamagandan.rasi, res.yamagandan.degree)}');
      print('மிருத்யு     (மிரு) : ${format360(res.mrityu.rasi, res.mrityu.degree)}');

      expect(res.isDay, isFalse);
      expect(res.currentYama, equals(3));
      expect(res.rahu.rasi, equals(3)); // மிதுனம் (Gemini - index 2)
      expect(res.yamagandan.rasi, equals(5)); // சிம்மம் (Leo - index 4)
      expect(res.mrityu.rasi, equals(3)); // மிதுனம் (Gemini - index 2)
    });
  });
}
