import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

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

  test('User Case: 11/10/2026 05:55:53 AM before sunrise is Saturday Night Segment 8 -> Dhanam (தனம்)', () async {
    final dt = DateTime(2026, 10, 11, 5, 55, 53);
    final planets = await KPService.calculateChart("Prasanam", dt, 11.2189, 78.1674, 5.5);
    final pancha = planets['panchangam'];

    final sr = parseTime(pancha['sunrise'], dt);
    final ss = parseTime(pancha['sunset'], dt);

    final seg = JamakkolService.calculateCurrentSegments(dt, sr, ss);
    expect(seg['segment'], 8);
    expect(seg['gowri'], "தனம்");
  });

  test('Daytime Case: 11/10/2026 07:00:00 AM after sunrise is Sunday Day Segment 1 -> Uthiyogam (உத்தியோகம்)', () async {
    final dt = DateTime(2026, 10, 11, 7, 0, 0);
    final planets = await KPService.calculateChart("Prasanam", dt, 11.2189, 78.1674, 5.5);
    final pancha = planets['panchangam'];

    final sr = parseTime(pancha['sunrise'], dt);
    final ss = parseTime(pancha['sunset'], dt);

    final seg = JamakkolService.calculateCurrentSegments(dt, sr, ss);
    expect(seg['segment'], 1);
    expect(seg['gowri'], "உத்தியோகம்");
  });
}
