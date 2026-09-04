import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrology_flutter/services/kp_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('4-Way Universal Matcher for Moon across all 4 Reference Charts', () async {
    // Chart 1: 03-09-2026 10:30 AM Chennai
    final pos1 = {'Sun': 4, 'Moon': 1, 'Mars': 2, 'Mercury': 4, 'Jupiter': 3, 'Venus': 6, 'Saturn': 11, 'Lagna': 6};
    final targetMoon1 = [3, 5, 3, 6, 6, 0, 5, 3, 3, 5, 5, 5];

    // Chart 2: 14-04-2026 5:59 PM Tirupur
    final pos2 = {'Sun': 0, 'Moon': 10, 'Mars': 11, 'Mercury': 11, 'Jupiter': 2, 'Venus': 0, 'Saturn': 11, 'Lagna': 5};
    final targetMoon2 = [3, 3, 5, 7, 4, 3, 4, 3, 5, 6, 4, 2];

    // Chart 3: 01-12-2026 6:00 AM Chennai
    final pos3 = {'Sun': 7, 'Moon': 4, 'Mars': 4, 'Mercury': 6, 'Jupiter': 4, 'Venus': 6, 'Saturn': 11, 'Lagna': 7};
    final targetMoon3 = [5, 6, 5, 3, 7, 4, 3, 1, 3, 7, 4, 1];

    // Chart 4: 01-01-2026 6:05 AM Tirupur
    final pos4 = {'Sun': 8, 'Moon': 1, 'Mars': 8, 'Mercury': 8, 'Jupiter': 2, 'Venus': 8, 'Saturn': 11, 'Lagna': 8};
    final targetMoon4 = [4, 5, 4, 5, 2, 6, 6, 1, 2, 4, 6, 4];

    List<int> evalPoints(Map<String, List<int>> table, Map<String, int> pos) {
      List<int> sar = List.filled(12, 0);
      table.forEach((refP, houses) {
        int rPos = pos[refP]!;
        for (int h in houses) sar[(rPos + h - 1) % 12]++;
      });
      return sar;
    }

    bool match(List<int> a, List<int> b) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) if (a[i] != b[i]) return false;
      return true;
    }

    final allMoonFromSun = [
      [3, 6, 7, 8, 10, 11],
      [3, 6, 8, 10, 11],
      [3, 7, 8, 10, 11],
    ];
    final allMoonFromMoon = [
      [1, 3, 6, 7, 10, 11],
      [1, 3, 6, 7, 10],
      [1, 3, 6, 7, 11],
    ];
    final allMoonFromMars = [
      [2, 3, 5, 6, 9, 10, 11],
      [2, 3, 5, 6, 8, 10, 11],
      [3, 5, 6, 9, 10, 11],
      [2, 3, 5, 6, 10, 11],
      [2, 3, 5, 6, 9, 11],
    ];
    final allMoonFromMerc = [
      [1, 3, 4, 5, 7, 8, 10, 11],
      [1, 3, 4, 5, 6, 8, 10, 11],
    ];
    final allMoonFromJup = [
      [1, 2, 4, 7, 8, 10, 11],
      [1, 4, 7, 8, 10, 11, 12],
      [2, 4, 7, 8, 10, 11, 12],
      [1, 2, 4, 7, 8, 11, 12],
      [4, 7, 8, 10, 11, 12],
    ];
    final allMoonFromVen = [
      [3, 4, 5, 7, 9, 10, 11],
      [3, 4, 5, 7, 9, 10],
      [3, 4, 5, 6, 7, 9, 10, 11],
      [1, 3, 4, 5, 7, 9, 10, 11],
      [4, 5, 7, 9, 10, 11],
      [3, 4, 5, 9, 10, 11],
      [3, 4, 7, 9, 10, 11],
      [3, 4, 5, 7, 10, 11],
      [2, 3, 4, 5, 7, 10, 11],
      [1, 2, 3, 4, 5, 7, 9, 10, 11],
      [3, 5, 6, 9, 10, 11],
      [3, 4, 5, 7, 8, 10, 11],
    ];
    final allMoonFromSat = [
      [3, 5, 6, 11],
      [3, 5, 6],
      [3, 6, 11],
      [3, 5, 6, 10, 11],
    ];
    final allMoonFromLag = [
      [3, 6, 10, 11],
      [1, 3, 6, 10, 11],
      [3, 4, 6, 10, 11],
      [4, 6, 10, 11],
      [3, 6, 11],
      [3, 6, 10],
      [1, 3, 6, 11],
    ];

    // Let's define the base candidates for each planet in Moon's BAV:
    final sOpts = [
      [3, 6, 7, 8, 10, 11],
      [2, 3, 6, 7, 8, 10, 11],
      [3, 6, 8, 10, 11],
    ];
    final mOpts = [
      [1, 3, 6, 7, 10, 11],
      [1, 3, 6, 7, 10],
      [1, 3, 6, 7, 11],
    ];
    final maOpts = [
      [2, 3, 5, 6, 9, 10, 11],
      [2, 3, 5, 6, 10, 11],
      [3, 5, 6, 9, 10, 11],
      [2, 3, 5, 6, 8, 10, 11],
      [1, 2, 3, 5, 6, 10, 11],
      [2, 3, 5, 6, 11],
    ];
    final meOpts = [
      [1, 3, 4, 5, 7, 8, 10, 11],
      [1, 2, 3, 4, 5, 7, 8, 10, 11],
      [2, 3, 4, 5, 7, 8, 10, 11],
      [1, 3, 4, 5, 6, 8, 10, 11],
      [1, 3, 4, 5, 7, 8, 11],
    ];
    final jOpts = [
      [1, 2, 4, 7, 8, 10, 11],
      [1, 4, 7, 8, 10, 11, 12],
      [2, 4, 7, 8, 10, 11, 12],
      [1, 2, 4, 7, 8, 11, 12],
      [4, 7, 8, 10, 11, 12],
      [1, 2, 4, 7, 8, 10, 11, 12],
    ];
    final vOpts = [
      [3, 4, 5, 7, 9, 10, 11],
      [2, 3, 4, 5, 7, 10, 11],
      [1, 3, 4, 5, 7, 10, 11],
      [3, 4, 5, 7, 8, 10, 11],
      [3, 4, 5, 7, 10, 11],
      [2, 3, 4, 5, 7, 9, 10, 11],
      [1, 2, 3, 4, 5, 7, 10, 11],
      [3, 4, 5, 7, 9, 10],
      [3, 4, 5, 7, 9, 11],
      [3, 4, 5, 7, 11],
    ];
    final satOpts = [
      [3, 5, 6, 11],
      [3, 5, 6, 10, 11],
      [3, 5, 6],
      [3, 6, 11],
      [5, 6, 11],
    ];
    final lagOpts = [
      [3, 6, 10, 11],
      [2, 3, 6, 10, 11],
      [1, 3, 6, 10, 11],
      [3, 4, 6, 10, 11],
      [3, 6, 11],
    ];

    final cand2 = {
      'Sun': [3, 6, 7, 8, 10, 11],
      'Moon': [1, 3, 6, 7, 10, 11],
      'Mars': [2, 3, 5, 6, 10, 11], // 6 bindus (no 9)
      'Mercury': [1, 3, 4, 5, 7, 8, 10, 11],
      'Jupiter': [1, 2, 4, 7, 8, 10, 11],
      'Venus': [3, 4, 5, 7, 9, 10, 11],
      'Saturn': [3, 5, 6, 11],
      'Lagna': [3, 6, 10, 11], // 4 bindus (standard)
    };
    // Sum is 48, so one planet has 1 more bindu. Let's see which:
    for (var extra in ['Sun', 'Moon', 'Mercury', 'Venus', 'Saturn', 'Lagna']) {
      for (int h = 1; h <= 12; h++) {
        var t = Map<String, List<int>>.from(cand2.map((k, v) => MapEntry(k, List<int>.from(v))));
        if (t[extra]!.contains(h)) continue;
        t[extra]!.add(h);
        t[extra]!.sort();

        final res1 = evalPoints(t, pos1);
        final res2 = evalPoints(t, pos2);
        final res3 = evalPoints(t, pos3);
        final res4 = evalPoints(t, pos4);

        if (match(res4, targetMoon4) && match(res3, targetMoon3)) {
          print("FOUND UNIVERSAL MATCH with $extra adding $h: $t");
          print("  res1: $res1 (target1: $targetMoon1) => ${match(res1, targetMoon1)}");
          print("  res2: $res2 (target2: $targetMoon2) => ${match(res2, targetMoon2)}");
          if (match(res1, targetMoon1) && match(res2, targetMoon2)) {
            print(">>> 100% PERFECT UNIVERSAL MATCH ACROSS ALL 4 CHARTS: $t");
          }
        }
      }
    }
  });
}
