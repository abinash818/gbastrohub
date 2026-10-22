import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/components/south_indian_chart.dart';

void main() {
  group('SouthIndianChart Degree-Wise Sorting', () {
    test('Aries to Scorpio: 0° top to 30° bottom (column / ascending)', () {
      final planets = [
        "சனி 24:10",
        "சூரி 05:30",
        "சுக்கிரன் 18:45",
      ];

      // Aries (English)
      final ariesSorted = SouthIndianChart.sortItemsByDegree(planets, rasi: "Aries");
      expect(ariesSorted, [
        "சூரி 05:30",
        "சுக்கிரன் 18:45",
        "சனி 24:10",
      ]);

      // Scorpio (Tamil: விருச்சிகம்)
      final scorpioSorted = SouthIndianChart.sortItemsByDegree(planets, rasi: "விருச்சிகம்");
      expect(scorpioSorted, [
        "சூரி 05:30",
        "சுக்கிரன் 18:45",
        "சனி 24:10",
      ]);

      // Leo (சிம்மம்)
      final leoSorted = SouthIndianChart.sortItemsByDegree(planets, rasi: "Leo");
      expect(leoSorted, [
        "சூரி 05:30",
        "சுக்கிரன் 18:45",
        "சனி 24:10",
      ]);
    });

    test('Sagittarius to Pisces: 0° bottom to 30° top (column-reverse / descending)', () {
      final planets = [
        "சூரி 05:30",
        "சுக்கிரன் 18:45",
        "சனி 24:10",
      ];

      // Sagittarius (தனுசு)
      final sagSorted = SouthIndianChart.sortItemsByDegree(planets, rasi: "Sagittarius");
      expect(sagSorted, [
        "சனி 24:10",
        "சுக்கிரன் 18:45",
        "சூரி 05:30",
      ]);

      // Capricorn (மகரம்)
      final capSorted = SouthIndianChart.sortItemsByDegree(planets, rasi: "மகரம்");
      expect(capSorted, [
        "சனி 24:10",
        "சுக்கிரன் 18:45",
        "சூரி 05:30",
      ]);

      // Aquarius (கும்பம்)
      final aquSorted = SouthIndianChart.sortItemsByDegree(planets, rasi: "Aquarius");
      expect(aquSorted, [
        "சனி 24:10",
        "சுக்கிரன் 18:45",
        "சூரி 05:30",
      ]);

      // Pisces (மீனம்)
      final pisSorted = SouthIndianChart.sortItemsByDegree(planets, rasi: "மீனம்");
      expect(pisSorted, [
        "சனி 24:10",
        "சுக்கிரன் 18:45",
        "சூரி 05:30",
      ]);
    });
  });
}
