import 'package:flutter_test/flutter_test.dart';
import 'package:astrology_flutter/services/kp_service.dart';
import 'package:astrology_flutter/services/jamakkol_service.dart';
import 'package:astrology_flutter/components/south_indian_chart.dart';
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

  test('Saturday Night Segment 8 before sunrise -> Rogam (ரோகம்)', () async {
    final dt = DateTime(2026, 10, 11, 5, 55, 53);
    final planets = await KPService.calculateChart("Prasanam", dt, 11.2189, 78.1674, 5.5);
    final pancha = planets['panchangam'];

    final sr = parseTime(pancha['sunrise'], dt);
    final ss = parseTime(pancha['sunset'], dt);

    final seg = JamakkolService.calculateCurrentSegments(dt, sr, ss);
    expect(seg['segment'], 8);
    expect(seg['gowri'], "ரோகம்");
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

  test('User Screenshot Case: 27/10/2026 12:29:10 PM is Tuesday Day Segment 5 -> Soram (சோரம்)', () async {
    final dt = DateTime(2026, 10, 27, 12, 29, 10);
    final planets = await KPService.calculateChart("Prasanam", dt, 11.2189, 78.1674, 5.5);
    final pancha = planets['panchangam'];

    final sr = parseTime(pancha['sunrise'], dt);
    final ss = parseTime(pancha['sunset'], dt);

    final seg = JamakkolService.calculateCurrentSegments(dt, sr, ss);
    expect(seg['segment'], 5);
    expect(seg['gowri'], "சோரம்");
  });

  test('Tuesday Rahu Kaalam: 27/10/2026 03:30:00 PM is Tuesday Day Segment 7 -> Visham (விஷம்)', () async {
    final dt = DateTime(2026, 10, 27, 15, 30, 0);
    final planets = await KPService.calculateChart("Prasanam", dt, 11.2189, 78.1674, 5.5);
    final pancha = planets['panchangam'];

    final sr = parseTime(pancha['sunrise'], dt);
    final ss = parseTime(pancha['sunset'], dt);

    final seg = JamakkolService.calculateCurrentSegments(dt, sr, ss);
    expect(seg['segment'], 7);
    expect(seg['gowri'], "விஷம்");
  });

  test('SouthIndianChart degree-wise sorting within rasi (lowest to highest)', () {
    final unsortedLeo = [
      "செவ் 06:28",
      "குரு 02:24",
      "மாந் 27:38",
    ];
    final sortedLeo = SouthIndianChart.sortItemsByDegree(unsortedLeo);
    expect(sortedLeo, [
      "குரு 02:24",
      "செவ் 06:28",
      "மாந் 27:38",
    ]);

    final unsortedCancer = [
      "கேது 29:50",
      "யம 11:17",
    ];
    final sortedCancer = SouthIndianChart.sortItemsByDegree(unsortedCancer);
    expect(sortedCancer, [
      "யம 11:17",
      "கேது 29:50",
    ]);

    final unsortedGemini = [
      "சந் 25:36",
      "ஆரூ 13:12",
    ];
    final sortedGemini = SouthIndianChart.sortItemsByDegree(unsortedGemini);
    expect(sortedGemini, [
      "ஆரூ 13:12",
      "சந் 25:36",
    ]);
  });

  test('User Screenshot: 28/11/2026 00:12:12 AM Arudam Lord Mercury is in 6th House from Udayam', () {
    final jamakkolRes = {
      'inner': {
        'planet_details': {
          'mercury': {
            'rasi': 'Libra',
            'longitude': 203.25,
          },
        },
      },
      'udayam_idx': 1, // Taurus (ரிஷபம்)
      'arudam_idx': 2, // Gemini (மிதுனம்) -> Lord is Mercury
      'kavi_idx': 1,   // Taurus
    };
    final notes = JamakkolService.calculateNotes(jamakkolRes);
    expect(notes['arudam_lord_house'], 6);
  });

  test('User Screenshot: 14-10-2026 18:25:15 PM Sootchuma Rasi', () async {
    final dt = DateTime(2026, 10, 14, 18, 25, 15);
    final inner = await KPService.calculateChart("Prasanam", dt, 11.2189, 78.1674, 5.5);
    double sunLon = (inner['planet_info']?['Sun']?['lon'] ?? 0.0).toDouble();
    int solarMonthIdx = (sunLon / 30).floor() % 12;
    final pancha = inner['panchangam'];
    final sr = parseTime(pancha['sunrise'], dt);
    final ss = parseTime(pancha['sunset'], dt);

    final outer = JamakkolService.calculate(
      dt, sr, 11.2189, 78.1674, 5.5, solarMonthIdx,
      sunLongitude: sunLon,
      sunset: ss,
    );
    int udayamIdx = outer['udayam_idx'] ?? 0;
    int arudamIdx = outer['arudam_sign_idx'] ?? 0;
    int sooryaVeethiIdx = outer['soorya_veethi_idx'] ?? 0;
    int kaviIdx = JamakkolService.calculateKavippu(udayamIdx, arudamIdx, sooryaVeethiIdx);

    final notes = JamakkolService.calculateNotes({
      'udayam_idx': udayamIdx,
      'arudam_idx': arudamIdx,
      'kavi_idx': kaviIdx,
      'inner': inner,
      'outer': outer,
      'udayam_abs_deg': outer['udayam_abs_deg'],
    });
    print("OUTER PLANET DEGREES 14-10: ${outer['planet_degrees']}");
    print("UDAYAM IDX: $udayamIdx (${KPService.SIGNS[udayamIdx % 12]})");
    print("ARUDAM IDX: $arudamIdx (${KPService.SIGNS[arudamIdx % 12]})");
    print("SOOTCHUMA: ${notes['sootchuma_details']}");
    expect(notes['sootchuma_details']['rasi'], equals("Leo"));
  });

  test('User Screenshot: 15-10-2026 20:01:18 PM Sootchuma Rasi', () async {
    final dt = DateTime(2026, 10, 15, 20, 1, 18);
    final inner = await KPService.calculateChart("Prasanam", dt, 11.2189, 78.1674, 5.5);
    double sunLon = (inner['planet_info']?['Sun']?['lon'] ?? 0.0).toDouble();
    int solarMonthIdx = (sunLon / 30).floor() % 12;
    final pancha = inner['panchangam'];
    final sr = parseTime(pancha['sunrise'], dt);
    final ss = parseTime(pancha['sunset'], dt);

    final outer = JamakkolService.calculate(
      dt, sr, 11.2189, 78.1674, 5.5, solarMonthIdx,
      sunLongitude: sunLon,
      sunset: ss,
    );
    int udayamIdx = outer['udayam_idx'] ?? 0;
    int arudamIdx = outer['arudam_sign_idx'] ?? 0;
    int sooryaVeethiIdx = outer['soorya_veethi_idx'] ?? 0;
    int kaviIdx = JamakkolService.calculateKavippu(udayamIdx, arudamIdx, sooryaVeethiIdx);

    final notes = JamakkolService.calculateNotes({
      'udayam_idx': udayamIdx,
      'arudam_idx': arudamIdx,
      'kavi_idx': kaviIdx,
      'inner': inner,
      'outer': outer,
      'udayam_abs_deg': outer['udayam_abs_deg'],
    });
    print("--- 15-10-2026 20:01:18 ---");
    print("UDAYAM: $udayamIdx (${KPService.SIGNS[udayamIdx % 12]})");
    print("ARUDAM: $arudamIdx (${KPService.SIGNS[arudamIdx % 12]})");
    print("ARUDAM LORD HOUSE: ${notes['arudam_lord_house']}");
    print("SOOTCHUMA: ${notes['sootchuma_details']}");
    expect(notes['arudam_lord_house'], equals(5));
    expect(notes['sootchuma_details']['rasi'], equals("Cancer"));
  });
}
